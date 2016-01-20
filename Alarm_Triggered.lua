-- Your smtp2go account user name
local MY_EMAIL = "email address you signed up to SMTPT2GO with" 

-- The SMTP2GO mail server and port number.
local SMTP_SERVER = "mail.smtp2go.com"
local SMTP_PORT = "2525"

-- Where you want to send the email to
local mail_to = "email address you want to send text too" 

-- These are global variables. Don't change their values
-- they will be changed in the functions below
local email_subject = ""
local email_body = ""
local count = 0

local smtp_socket = nil -- will be used as socket to email server

-- The display() function will be used to print the SMTP server's response
function display(sck,response)
     print(response)
end

-- The do_next() function is used to send the SMTP commands to the SMTP server in the required sequence.
-- I was going to use socket callbacks but the code would not run callbacks after the first 3.
function do_next()
            if(count == 0)then
                count = count+1
                local IP_ADDRESS = wifi.sta.getip()
                smtp_socket:send("HELO "..IP_ADDRESS.."\r\n")
            elseif(count==1) then
                count = count+1
               smtp_socket:send("MAIL FROM:<" .. MY_EMAIL .. ">\r\n")
            elseif(count==2) then
                count = count+1
               smtp_socket:send("RCPT TO:<" .. mail_to ..">\r\n")
            elseif(count==3) then
                count = count+1
               smtp_socket:send("DATA\r\n")
            elseif(count==4) then
                count = count+1
                local message = string.gsub(
                "From: \"".. MY_EMAIL .."\"<"..MY_EMAIL..">\r\n" ..
                "To: \"".. mail_to .. "\"<".. mail_to..">\r\n"..
                "Subject: ".. email_subject .. "\r\n\r\n"  ..
                email_body,"\r\n.\r\n","")
                
                smtp_socket:send(message.."\r\n.\r\n")
            elseif(count==5) then
               count = count+1
                 tmr.stop(0)
                 smtp_socket:send("QUIT\r\n")
            else
               smtp_socket:close()
            end
end

-- The connectted() function is executed when the SMTP socket is connected to the SMTP server.
-- This function will create a timer to call the do_next function which will send the SMTP commands
-- in sequence, one by one, every 5000 seconds. 
-- You can change the time to be smaller if that works for you, I used 5000ms just because.
function connected(sck)
    tmr.alarm(0,500,1,do_next)
end

-- @name send_email
-- @description Will initiated a socket connection to the SMTP server and trigger the connected() function
-- @param subject The email's subject
-- @param body The email's body
function send_email_1(subject,body)
     count = 0
     email_subject = subject
     email_body = body
     smtp_socket = net.createConnection(net.TCP,0)
     smtp_socket:on("connection",connected)
     smtp_socket:on("receive",display)
     smtp_socket:connect(SMTP_PORT,SMTP_SERVER)
end

-- Send an email
send_email_1("Alarm Triggered",
[[Alert From ESP8266 Module #1, Your Home Alarm System has been triggered]])
    


