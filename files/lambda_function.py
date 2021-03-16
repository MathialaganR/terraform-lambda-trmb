import boto3
import csv


ec2_re = boto3.resource('ec2')
ec2_cl = boto3.client('ec2')
s3 = boto3.resource('s3')
bucket = s3.Bucket('rmathi-ec2-inventory')
key = 'inventory.csv'
sns = boto3.client('sns')
SNS_TOPIC_ARN = 'arn:aws:sns:us-west-2:890090367563:tagtrigger'
CODES = ["Data", "Processing", "Web"]

result = []

def ec2_inventory():
    response = ec2_cl.describe_instances(Filters=[{'Name' : 'instance-state-name','Values' : ['running']}]).get(
        'Reservations', []
    )
    return response
    
def get_noncompliant(response):
    noncompliant_ec2 = []
    for item in response:
        service_key = False
        service_value = " "
        for each in item['Instances']:
            for tag in each['Tags']:
                if tag['Key'] == 'Service':
                    service_key = True
                    service_value = tag['Value']
        if service_key == False:
            noncompliant_ec2.append(item)
        elif service_value not in CODES:
            noncompliant_ec2.append(item)
        else:
            pass
    return noncompliant_ec2
    
def send_notification(response):
    noncompliant_ec2 = get_noncompliant(response)
    ec2_notify = []
    for a in noncompliant_ec2:
        Instance_name =  ''
        for each in a['Instances']:
            for tag in each['Tags']:
                if tag['Key'] == 'Name':
                    Instance_name = tag['Value']
        ec2_notify.append({'instanceid' : a['Instances'][0]['InstanceId'],
                           'Instance Name' : Instance_name})
    if len(ec2_notify) != 0:
        report = ''
        for a in ec2_notify:
            report += f" InstanceID : {a['instanceid']} InstanceName : {a['Instance Name']}  "
            report += "\n"
        sns.publish(TopicArn=SNS_TOPIC_ARN, Message=report)
    
def inventory(response):
    for item in response:
        for each in item['Instances']:
            for tag in each['Tags']:
                result.append({
                    'Name': tag['Value'],
                    'ImageId': each['ImageId'],
                    'InstanceType': each['InstanceType'],
                    'Tags': each['Tags']
                    })
            
            
    header = ['Name', 'ImageId', 'InstanceType', 'Tags']
    with open('/tmp/ec2-details.csv', 'w') as file:
        writer = csv.DictWriter(file, fieldnames=header)
        writer.writeheader()
        writer.writerows(result)
        
    bucket.upload_file('/tmp/ec2-details.csv', key)
    
    


def lambda_handler(event, context):
    response = ec2_inventory()
    inventory(response)
    
    if event['Test'] != "True":
        send_notification(response)
        
        
    

 
   