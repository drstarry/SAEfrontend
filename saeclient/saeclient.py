#!env python

from collections import defaultdict
import rpc_pb2
import interface_pb2
import zmq
import threading

context = zmq.Context()


def request(server, method, params):
    socket = context.socket(zmq.REQ)
    socket.connect(server)

    request = rpc_pb2.Request()
    request.method = method
    request.param = params

    socket.send(request.SerializeToString())
    reply = socket.recv()
    response = rpc_pb2.Response.FromString(reply)

    return response.data


def pbrequest(server, method, params):
    params = params.SerializeToString()
    response = request(server, method, params)
    return response


class SAEClient(object):
    def __init__(self, endpoint):
        self.endpoint = endpoint
        # entity_cache = method : { id : entity }
        self.entity_cache = defaultdict(dict)
        self.entity_cache_lock = threading.Lock()

    def echo_test(self, s):
        return request(self.endpoint, "echo_test", s)

    def _entity_search(self, method, query, offset, count):
        r = interface_pb2.EntitySearchRequest()
        r.dataset = ""
        r.query = query
        r.offset = offset
        r.count = count
        response = pbrequest(self.endpoint, method, r)
        er = interface_pb2.EntitySearchResponse()
        er.ParseFromString(response)
        return er

    def _entity_detail_search(self, method, ids):
        self.entity_cache_lock.acquire()
        r = interface_pb2.EntityDetailRequest()
        er = interface_pb2.EntitySearchResponse()
        r.dataset = ""
        cached = []
        for id in ids:
            if id not in self.entity_cache[method]:
                r.id.append(id)
            else:
                cached.append(id)
        if len(r.id):
            response = pbrequest(self.endpoint, method, r)
            er.ParseFromString(response)
        for e in er.entity:
            self.entity_cache[method][e.id] = e
        er.entity.extend([self.entity_cache[method][id] for id in cached])
        self.entity_cache_lock.release()
        if er.total_count < len(er.entity):
            er.total_count = len(er.entity)
        return er

    def person_search(self, query, offset=0, count=20):
        return self._entity_search("PersonSearch", query, offset, count)

    def mail_search(self, query, offset=0, count=20):
        return self._entity_search("MailSearch", query, offset, count)

    def detail_search_by_id(self, ids):
        return self._entity_detail_search("DetailSearchById", ids)

    def mail_detail_search_by_id(self,ids):
        return self._entity_detail_search("MailDetailSearchById",ids)

    def person_detail_search_by_id(self, ids):
        return self._entity_detail_search("PersonDetailSearchById", ids)


def main():
    c = SAEClient("tcp://localhost:40119")
    print c.person_search("enron")
    print c.detail_search_by_id([1, 2])


if __name__ == "__main__":
    main()
