#!/usr/bin/python3

import argparse
from datetime import datetime
import json
import os
import requests
import urllib3
urllib3.disable_warnings()

def upload_results(host, api_key, scanner, result_file, engagement_id, lead_id, environment, verify=False): # set verify to False if ssl cert is self-signed
    API_URL = "http://"+host+"/api/v2"
    IMPORT_SCAN_URL = API_URL+"/import-scan/"
    AUTH_TOKEN = "Token "+api_key

    headers = dict()
    json = dict()
    files = dict()

    # Prepare headers
    # headers = {'Authorization': 'Token xxx'}
    headers['Authorization'] = AUTH_TOKEN
    print(headers)

    # Prepare JSON data to send to API
    # json= {
    #   "minimum_severity": "Low",
    #   "scan_date": datetime.now().strftime("%Y-%m-%d"),
    #   "verified": False,
    #   "active": False,
    #   "engagement": 1,
    #   "lead": 1,
    #   "scan_type": "Bandit Scan",
    #   "tags": []
    # }
    json['minimum_severity'] = "Low"
    json['scan_date'] = datetime.now().strftime("%Y-%m-%d")
    json['verified'] = False
    json['active'] = False
    json['engagement'] = engagement_id
    json['lead'] = lead_id
    json['scan_type'] = scanner
    json['environment'] = environment
    print(json)

    # Prepare file data to send to API
    files['file'] = open(result_file)

    # Make a request to API
    response = requests.post(IMPORT_SCAN_URL, headers=headers, files=files, data=json, verify=verify)
    # Uncomment these lines to debug
    # print(response.request.body)
    # print(response.request.headers)
    # print(response.status_code)
    # print(response.text)
    return response.status_code

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='CI/CD integration for DefectDojo')
    parser.add_argument('--host', help="DefectDojo Hostname", required=True)
    parser.add_argument('--api_key', help="API v2 Key", required=True)
    parser.add_argument('--engagement_id', help="Engagement ID", required=True)
    parser.add_argument('--result_file', help="Scanner file", required=True)
    parser.add_argument('--scanner', help="Type of scanner", required=True)
    parser.add_argument('--product_id', help="DefectDojo Product ID", required=True)
    parser.add_argument('--lead_id', help="ID of the user conducting the testing", required=True)
    parser.add_argument('--environment', help="Environment name", required=True)
    parser.add_argument('--build_id', help="Reference to external build id", required=False)

    # Parse out arguments
    args = vars(parser.parse_args())
    host = args["host"]
    api_key = args["api_key"]
    product_id = args["product_id"]
    result_file = args["result_file"]
    scanner = args["scanner"]
    engagement_id = args["engagement_id"]
    lead_id = args["lead_id"]
    environment = args["environment"]
    build_id = args["build_id"]

    # upload_results(self, host, api_key, scanner, result_file, engagement_id, verify=False): # set verify to False if ssl cert is self-signed
    result = upload_results(host, api_key, scanner, result_file, engagement_id, lead_id, environment)
    if result == 201 :
         print("Successfully uploaded the results to Defect Dojo")
    else:
         print("Something went wrong, please debug " + str(result))