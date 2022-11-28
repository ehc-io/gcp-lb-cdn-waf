# Terraform template for GCE environment with:
    -  NGINX
    -  Global LB
    -  Cloud Armor
    -  Cache CDN (Logging enabled)

## Variables required
- Project-ID (name for your project)  
- Billing Account ID (format: 1A1A1A-2B2B2B-3C3C3C)  
    `gcloud billing accounts list`
- Org-ID (format: 123456789)  
    `gcloud projects get-ancestors <project-id>`

## How to use 

1. Clone the repo:   
    `git clone <repo-url>`

2. To deploy:

    - Change variables.tf accordingly. Everything as default already works you only need to provide:  
        - \<project-id>  
        - \<some-remote-ip-for-tests> - remote ip for white listing  [ HTTP ]   
        - \<service-account>
        
3. From the repo folder run the following commands:  
    `terraform init`   
    `terraform apply -auto-approve -var`             

    *Deployment takes about 6-8 minutes to be operational and ready for taking  http requests*

- Set variables  
    `exploit="cmd%3D%3B%20cat%20%2Fetc%2Fpasswd" ;`  
    `user="user1" ;`  
    `user_agent="my-header" ;`  
    `url_path="/index.nginx-debian.html?user=$user" ;`  
    `url_good="http://ehc-google.com$url_path" ;`  
    `url_bad="http://ehc-google.com$url_path&$exploit" ;` 

## Run your tests:

- Caching tests
    - Prints headers, response times & html outputs:  
    `curl -w "%{time_total}\n" -s -D - -H "User-Agent: <random-string>" http://<lb-hostname>`

    - Prints only response times:  
    `date +%s ; for i in {1..3}; do curl -s -w "%{time_total}\n" -H "User-Agent: <random-string>" -o /dev/null http://<lb-hostname>; done`

        *\<random-string> helps identify requests in Log Explorer*

- Waf tests:

    `curl -w "%{time_total}\n" -s -D - -H "User-Agent: $user_agent" $url_bad`