The task is to Develop a shell script that:

1.Create a file named create_users.sh

2.Reads input from a text file (users.txt) containing usernames and their respective groups.

3.Creates each user with:
   A personal primary group (same name as the username).
   Additional (supplementary) groups as specified.
   A home directory with secure permissions (750).

4.Generates a random password for every new user.

5.Stores all generated passwords in a secure CSV file (/var/secure/user_passwords.csv) accessible only by the root user.

6.Maintains a detailed log file (/var/log/user_management.log) for every action performed — including user creation, group assignments, and error handling.

7. Handles existing users or groups gracefully, avoiding duplicate entries or script failure.

INPUT FILES :-
1.users.sh
2.users.text

To Run the script:-
1. Save the scriptwith vi users.sh
2. Make it executable: chmod +x users.sh
3. Run with your input file: sudo bash users.sh users.txt
4. To check logs: sudo tail -n 20 /var/log/user_management.log
5. To check generated passwords:  sudo cat /var/secure/user_passwords.csv
6. <img width="473" height="61" alt="Capture" src="https://github.com/user-attachments/assets/bd0e60fb-a07b-4ca2-8c86-9b4b6b7e6f8a" />

  
Conclusion:-
This automation streamlines user management and improves security hygiene.

