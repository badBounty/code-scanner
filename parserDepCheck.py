import json
import sys

def parserDC(fname, to):
    vulns = []
    try:
        with open(fname, 'r') as f:
            lines = f.readlines()[1:]
            for line in lines:
                l = line.split(',')
                try:
                    dependency = l[3]
                    if (not(dependency in vulns)):
                        vulns.append(dependency)
                except:
                    print("Error:\n")
                    print(sys.exc_info())
    except:
        print("Error:\n")
        print(sys.exc_info())    
    json.dump(vulns, open(to, 'w'), indent=2, sort_keys=True)

parserDC(sys.argv[1], sys.argv[2])