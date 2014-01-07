#!env python2
#encoding: utf8

import sys
import os.path
from bottle import route, run, template, view, static_file, request, urlencode
from saeclient import SAEClient
import logging
import time
import json
import MySQLdb
import google.protobuf

logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)
#外网登陆
client = SAEClient("tcp://166.111.134.53:40112")
db=MySQLdb.connect(host="166.111.134.53",user="root",
                  passwd="keg2012",db="enron")
#内网登陆
#client = SAEClient("tcp://10.1.1.111:40112")
#db=MySQLdb.connect(host="10.1.1.110",user="root",
#                    passwd="keg2012",db="enron")

f_in = open("static/topic.json")
topic_data = json.load(f_in)
cursor = db.cursor()

logging.info("init done")

from md5 import md5
def gravatar(email):
    return md5(email.strip().lower()).hexdigest()

@route('/hello/<name>')
def index(name):
    return template('<b>Hello {{name}} </b>', name = name)

@route('/')
def index():
    return template('index')

@route('/enron/network/')
def search():
    return template('enron')

@route('/enron/topic/')
def search():
    return template('cloud')

@route('/enron/topic/data/<tid:int>')
def topic(tid):
    topics = []
    sorted_topic = sorted(topic_data[tid].items(), key=lambda x: x[1], reverse=True)
    for k in sorted_topic[:50]:
        topics.append({"text":k[0],"size":int(k[1]/100),"topic":tid})
    return json.dumps(topics)


@route('/enron/network/position/')
def position():
    output = {}
    with open("static/employee.json") as f_in:
        pos = json.load(f_in)
    f_in = open("enron_raltion_gt.txt")

    pid = {}
    role = {}
    for line in f_in:
        x = line.strip().split(" ")
        if len(x) < 3:
            continue
        cursor.execute("select * from employeelist where firstName='%s' and lastName='%s'"%(x[1], x[2]))
        data = cursor.fetchall()
        if len(data) > 0:
            # print data
            role[x[1]+" "+x[2]] = data[0][8]
            cursor.execute("select * from people where email='%s'" % data[0][3])
            peo = cursor.fetchall()
            if len(peo) == 0:
                print data[0][3]
            else:
                pid[x[1]+" "+x[2]] = peo[0][0]

    output["role"] = role
    output["pid"] = pid
    return json.dumps(output)


@route('/enron/network/graph/<pid:int>')
def graph(pid):
    output = {}
    emails = []
    ids = set()
    profile = {}
    cursor.execute("select * from mailgraph where senderid=%d or recipientid=%d" % (pid, pid))
    data = cursor.fetchall()
    for row in data:
        ids.add(row[0])
        ids.add(row[1])
    ids_str = ",".join([str(i) for i in ids])
    # print ids_str
    cursor.execute("select * from people where personid in (%s)" % ids_str)
    data = cursor.fetchall()
    for row in data:
        profile[row[0]] = row
    cursor.execute("select * from mailgraph where senderid in (%s) and recipientid in (%s)" % (ids_str, ids_str))
    data = cursor.fetchall()
    for row in data:
        if row[2] > 1:
            emails.append({"sender":profile[row[0]][2], "sid":row[0], "recipient":profile[row[1]][2], "rid":row[1], "messages":row[2]})
    output["profiles"] = profile
    output["emails"] = emails
    return json.dumps(output)

#email timeline page
@route('/enron/search/mail-list')
@view('mail-list')
def maillist():
    usrid = int(request.query.q1)
    cursor.execute("select * from people where (personid = (%d))" % (usrid))
    person = cursor.fetchall()
    # cursor.execute("select mail")

    #get 
    usr = []
    for i in person:
        print i
        usr.append(i)
    email = usr[0][1]
    name = usr[0][2]
    offset = int(request.query.offset or 0)
    count = int(request.query.count or 20)
    cursor.execute("select * from alledge where sid = (%d) OR rid = (%d) order by messagedt " % (usrid,usrid))
    record = cursor.fetchall()

    allsender = []
    allrecipient = []
    for row in record:
        allsender.append(row[3])
        allrecipient.append(row[6])
    allsender = set(allsender)
    allrecipient = set(allrecipient)
    s_record = [[]*255000 for row in range(255000)]
    r_record = [[]*255000 for row in range(255000)]
    
    mail_list = []
    sender = [[]*255000 for row in range(255000)]
    recipient = [[]*255000 for row in range(255000)]

    idx = 0
    subject = []
    mailid = []
    date = []
    print len(record)
    for x,row in enumerate(record):
        # print x,row[2]
        if row[0] not in mailid:
            sender[idx].append({
            "id":row[3],
            "name":row[4],
            "email":row[5]
            })
            recipient[idx].append({
            "id":row[6],
            "name":row[7],
            "email":row[8]
            })
            idx = idx+1
            subject.append(row[2])
            mailid.append(row[0])
            date.append(row[1])
        else:
            recipient[idx].append({
            "id":row[6],
            "name":row[7],
            "email":row[8]
            })

    for idx,x in enumerate(mailid):
        mail_list.append({
            "mailid":mailid[idx],
            "subject":subject[idx],
            "date":date[idx],
            "sender": ", ".join([
                     " %s <%s>\n" %(s["name"],s["email"])for s in sender[idx]
                    ]
                    ),
            "recipients": ", ".join([
                    " %s <%s>\n" %(s["name"],s["email"])for s in recipient[idx]
                        ])

            })
        
    for row in mail_list:
        for p in allsender:
            if p in row[3]:
                s_record.append(row)
        for p in allrecipient:
            if p in row[4]:
                r_record.append(row)
                
    return dict(
	
        query = usrid,
        name = name+"<"+email+">" ,
        results1 = [
                dict(
                    link = "/enron/mail/%s" % x["mailid"],
                    subject = x["subject"] ,
                    # body = x["body"],
                    sender = x["sender"] ,
                    recipients = x["recipients"],
                    date = x["date"]
                )for x in mail_list
                ],
	result2 = [
            dict(
                    link = "/enron/mail/%s" % x["mailid"],
                    subject = x["subject"] ,
                    # body = x["body"],
                    sender = x["sender"] ,
                    recipients = x["recipients"],
                    date = x["date"]
                )for x in s_record],
	result3 = [
            dict(
                    link = "/enron/mail/%s" % x["mailid"],
                    subject = x["subject"] ,
                    # body = x["body"],
                    sender = x["sender"] ,
                    recipients = x["recipients"],
                    date = x["date"]
                )for x in r_record]
            )

@route('/enron/search')
@view('search')
def search():
    q = request.query.q or ''
    offset = int(request.query.offset or '0')
    count = int(request.query.count or '20')
    print 'searching', q, 'in Enron'
    result = client.person_search(q, offset, count)
    mail_result = client.mail_search(q, 0, 20)
    return dict(
        query=q,
        encoded_query=urlencode({"q": result.query.encode('utf8')}),
        hotqueries=["data mining", "deep learning"],
        offset=offset,
        count=count,
        total_count=result.total_count,
        trends_enabled=False,
        influence_enabled=False,
        results_title='People',
        results=[
            dict(
                id = e.original_id,
                name="%s <%s>" % (e.title, e.url),
                url="mailto:%s" % e.url,
                description=e.description,
                stats=dict(
                    (s.type, s.value) for s in e.stat
                ),
                topics=[t.title() for t in e.topics.split(',') if t.strip()],
                imgurl="http://www.gravatar.com/avatar/" + gravatar(e.url) + "?d=identicon"
            ) for x,e in enumerate(result.entity)
        ],
        extra_results_list=[
            dict(

                title="Mails",
                items=[
                    dict(
                        id = "mail/%s" % e.original_id,
                        text=e.title,
                        link="mail/%s" % e.id,
                        stats=dict(
                            (s.type, s.value) for s in e.stat
                        ),
                        authors=[]
                    ) for e in mail_result.entity
                ]
            ),
        ]
    )

	
@route('/enron/mail/<messageid:int>')
@view('mail')
def showmail(messageid):
    mail = client.mail_detail_search_by_id([messageid]).entity[0]
	
    sender = client.detail_search_by_id(mail.related_entity[0].id).entity
    recipients = client.detail_search_by_id(mail.related_entity[1].id).entity
    return {
        "subject": mail.title,
        "body": mail.description,
        "sender": ", ".join(["%s <%s>" % (s.title, s.url) for s in sender]),
		"s_sum":len(sender),
        "recipients": ", ".join(["%s <%s>" % (s.title, s.url) for s in recipients]),
		"r_sum":len(recipients)
    }

@route('/static/<path:path>')
def static(path):
    curdir = os.path.dirname(os.path.realpath(__file__))
    return static_file(path, root=curdir + '/static/')

if len(sys.argv) > 1:
    port = int(sys.argv[1])
else:
    port = 8088 

print port
run(server='auto', host='localhost', port=port, reloader=True, debug=True)
