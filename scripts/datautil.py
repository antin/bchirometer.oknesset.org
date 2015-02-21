#!env python
import json, os, re, sys
print 'args: ', sys.argv
current_dir = os.getcwd()
print 'current_dir: ', current_dir
os.chdir(os.path.join(os.path.dirname(sys.argv[0]), '../data'))

paths = dict(
    member = r'member.json',
    agenda = r'agenda.json',
    party = r'party.json',
    combined = r'combined_newbies.json',
    member_agendas = r'member-agendas/member-agendas.%d.json',
)
def load_json(path):
    try:
        return json.load(open(path))
    except:
        print 'Error with %s' % path 
        print "Unexpected error:", sys.exc_info()[0]
data = { k:load_json(v) for k,v in paths.items() if '%' not in v }
os.chdir(current_dir)

prefix = 'if (!window.mit) window.mit = {};\nwindow.mit.%s = '
def do_file(path, variable=None):
    path_split = os.path.splitext(path)
    print 'do_file path: ', path
    if path_split[1] == '.json':	
        path = path_split[0]
    in_path = path + '.json'
    out_path = path + '.jsonp'
    if not variable:
        variable = os.path.basename(path)
    data = json.load(open(in_path))
    out_file = open(out_path, 'w')
    out_file.write(prefix % (variable))
    json.dump(data, out_file, indent=4)

if len(sys.argv) > 1 and sys.argv[1] == 'jsonp':
    do_file(sys.argv[2])

def process_member_agenda(member_agenda):
    res = {}
    for agenda in member_agenda['agendas']:
        res[agenda['id']] = agenda['score']
    return res

def combine_agendas(member_path, member_agendas_path, output_path):
    print '*** combine_agendas ***'
    print 'member_path: %s' % member_path
    print 'member_agendas_path: %s' % member_agendas_path
    print 'output_path: %s' % output_path
    current_dir = os.getcwd()
    print 'current_dir: ', current_dir
    data = json.load(open(current_dir + '/' + member_path))
    for member in data['objects']:
        #print 'Handling member: %d' % member['id']
        member_agenda = json.load(open(current_dir + '/' + member_agendas_path % member['id']))
        member['name'] = member['name']
        member['agendas'] = process_member_agenda(member_agenda)
    json.dump(data, open(current_dir + '/' + output_path, 'w'), indent=4)

if len(sys.argv) > 1 and sys.argv[1] == 'combine':
    combine_agendas(paths['member'], paths['member_agendas'], sys.argv[2])