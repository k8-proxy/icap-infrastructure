# Creating ICAP-Servers on AWS

Follow the below steps to deploy icap-server in AWS.

- Login to aws console https://aws.amazon.com/console/
- Go to EC2 service
- Choose Ireland, "eu-west-1" region
- Search for "AMI" under "Images"
- Sort "Creation Date" column to get latest AMIs
- Select latest AMI with name "icap-server"
- Click on "Launch" button

    ![image](https://user-images.githubusercontent.com/64204445/105376034-525d5a00-5c2f-11eb-9971-94350e4b3793.png)
  
- Select below configarature for next steps (available on bottom right corner):
        
        - Choose Instance Type         :     c4.8xlarge ( For load testing we generally use c4.8xlarge but ask to requester which flavour he wants to use ) 
        - Configure Instance Details   :     The amount of requested instances 
        - Add Storage (disk space)     :     At least 50G
        - Add Tags                     :     Can be skipped
        - Configure Security Group     :     Choose to select from existing groups, and select *launch-wizard-8*
                           

    ![Capture](https://user-images.githubusercontent.com/70108899/105423322-98bdb380-5c45-11eb-87fc-491b2218e612.PNG)

- Once you verify above details, `LAUNCH` the instance. You will be prompt to enter privet key. Choose existing or create a new pem file.
    
- Wait untill the instance goes to running state

- Get the Public IP of the instance

- To test the icap-server, use below command and verify output should be similar to below screenshot.
  ( c-icap should be installed before this step )

       curl https://owasp.org/www-pdf-archive//01_18_10_OWASP_Newsletter.pdf --output sample.pdf
       /usr/bin/c-icap-client -i <IP> -p 1345 -tls -tls-no-verify -s gw_rebuild -f sample.pdf -o rebuilt.pdf -v
       
    ![image](https://user-images.githubusercontent.com/64204445/105380046-7c188000-5c33-11eb-883d-7e371ba111b6.png)

