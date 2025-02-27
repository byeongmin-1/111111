
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>IP Logger</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

    <div class="container">
        <h1>Enter Your Name</h1>
        <input type="text" id="visitor-name" placeholder="Your Name">
        <button onclick="sendData()">Submit</button>
        <p id="ip-address">Fetching IP...</p>
    </div>

    <script>
        async function sendData() {
            const visitorName = document.getElementById("visitor-name").value.trim();
            if (!visitorName) {
                alert("⚠️ Please enter your name!");
                return;
            }

            try {
                // Fetch IP Address
                let response = await fetch("https://api64.ipify.org?format=json");
                if (!response.ok) throw new Error("Failed to fetch IP");
                
                let data = await response.json();
                document.getElementById("ip-address").innerText = "Your IP: " + data.ip;
                const requestData = { name: visitorName, ip: data.ip };

                // Send to Backend (Spring Boot)
                fetch("http://yourserver.com/api/send-ip", { // Replace with actual backend URL
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(requestData)
                }).catch(err => console.error("Backend Error:", err));

                // Send to Google Sheets
                fetch("https://script.google.com/macros/s/AKfycbxf04wi_7qteKdfqwwoD2Pt-WuC4O28QY91Q4BGlVJAmLEJJv1MkC9aqDi5-aT0sor0/exec", {
                    method: "POST",
                    headers: { "Content-Type": "application/x-www-form-urlencoded" },
                    body: new URLSearchParams({ ip: data.ip, name: visitorName }) // Fixed formatting
                }).catch(err => console.error("Google Sheets Error:", err));

            } catch (error) {
                console.error("Error fetching IP:", error);
                alert("⚠️ Failed to fetch IP. Check console for details.");
            }
        }
    </script>

</body>
</html>
/* General page styling */
body {
  background: #20262E;
  color: white;
  padding: 20px;
  font-family: Helvetica, Arial, sans-serif;
  text-align: center;
}

/* Container styling */
.container {
  background: #fff;
  color: #333;
  border-radius: 8px;
  padding: 20px;
  width: 50%;
  margin: auto;
  box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.3);
  transition: all 0.3s ease-in-out;
}

/* Heading */
h1 {
  font-weight: bold;
  font-size: 24px;
  margin-bottom: 15px;
}

/* Input field */
input {
  width: 80%;
  padding: 10px;
  border: 2px solid #007bff;
  border-radius: 5px;
  font-size: 16px;
  margin-bottom: 10px;
  outline: none;
  text-align: center;
}

/* Button styling */
button {
  background-color: #007bff;
  color: white;
  border: none;
  padding: 10px 15px;
  font-size: 16px;
  cursor: pointer;
  border-radius: 5px;
  transition: all 0.3s ease-in-out;
}

button:hover {
  background-color: #0056b3;
  transform: scale(1.05);
}

/* IP address text */
#ip-address {
  font-size: 18px;
  font-weight: bold;
  color: #007bff;
  margin-top: 10px;
}

/* Hover effect on container */
.container:hover {
  transform: scale(1.02);
}

/* Responsive Design */
@media (max-width: 768px) {
  .container {
    width: 90%;
    padding: 15px;
  }

  input {
    width: 100%;
  }
}
package com.example.iptracker;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class IPController {

    @Autowired
    private JavaMailSender mailSender;

    @PostMapping("/send-ip")
    public String sendIP(@RequestBody IPRequest request) {
        if (request.getIp() == null || request.getIp().isEmpty() ||
            request.getName() == null || request.getName().isEmpty()) {
            return "Invalid IP or Name!";
        }

        sendEmail(request.getName(), request.getIp());
        return "IP & Name Sent Successfully!";
    }

    private void sendEmail(String name, String ip) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo("byeongminchoi12@gmail.com");
        message.setSubject("New Visitor Logged");
        message.setText("Visitor Name: " + name + "\nIP Address: " + ip);

        try {
            mailSender.send(message);
            System.out.println("Email sent successfully!");
        } catch (Exception e) {
            System.err.println("Error sending email: " + e.getMessage());
        }
    }
}
