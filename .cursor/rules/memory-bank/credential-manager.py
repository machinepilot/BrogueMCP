#!/usr/bin/env python3
"""
Credential Manager for Ages of Arda project
Securely stores and retrieves API keys and credentials
"""

import os
import sys
import json
import base64
import hashlib
import argparse
import datetime
from pathlib import Path
from getpass import getpass
import uuid

try:
    from cryptography.fernet import Fernet
    from cryptography.hazmat.primitives import hashes
    from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
except ImportError:
    print("Missing required packages. Install with: pip install cryptography")
    sys.exit(1)

# Constants
CREDENTIALS_DIR = Path(".memory-bank/.credentials")
CONFIG_FILE = CREDENTIALS_DIR / "config.json"
MASTER_KEY_FILE = CREDENTIALS_DIR / "master.key"
SALT_FILE = CREDENTIALS_DIR / "salt.bin"

def initialize_store():
    """Initialize the credential store"""
    # Create directory if it doesn't exist
    CREDENTIALS_DIR.mkdir(parents=True, exist_ok=True)
    
    if not SALT_FILE.exists():
        # Generate a random salt
        salt = os.urandom(16)
        with open(SALT_FILE, "wb") as file:
            file.write(salt)
        print("Salt generated")
    
    if not CONFIG_FILE.exists():
        # Create initial config file
        config = {
            "version": "1.0",
            "credentials": {}
        }
        with open(CONFIG_FILE, "w") as file:
            json.dump(config, file, indent=2)
        print("Config file created")
    
    if not MASTER_KEY_FILE.exists():
        # Set up master key
        password = getpass("Create master password for credentials: ")
        confirm = getpass("Confirm master password: ")
        
        if password != confirm:
            print("Passwords do not match!")
            sys.exit(1)
        
        # Generate master key from password
        salt = open(SALT_FILE, "rb").read()
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(password.encode()))
        
        # Store master key (should be in secure enclave in production)
        with open(MASTER_KEY_FILE, "wb") as file:
            file.write(key)
        print("Master key created")
    
    print("Credential store initialized")

def get_encryption_key():
    """Get the encryption key for credential storage"""
    if not MASTER_KEY_FILE.exists():
        print("Master key not found. Initialize the store first.")
        sys.exit(1)
    
    # In production, this should use a more secure method for key storage
    with open(MASTER_KEY_FILE, "rb") as file:
        return file.read()

def store_credential(name, value, vault="default"):
    """Store a credential"""
    key = get_encryption_key()
    fernet = Fernet(key)
    encrypted_value = fernet.encrypt(value.encode())
    
    # Update config
    with open(CONFIG_FILE, "r") as file:
        config = json.load(file)
    
    if vault not in config["credentials"]:
        config["credentials"][vault] = {}
    
    credential_id = str(uuid.uuid4())
    config["credentials"][vault][name] = {
        "id": credential_id,
        "created": datetime.datetime.now().isoformat(),
        "type": "encrypted"
    }
    
    # Store in config file
    with open(CONFIG_FILE, "w") as file:
        json.dump(config, file, indent=2)
    
    # Store encrypted value
    credential_file = CREDENTIALS_DIR / f"{credential_id}.enc"
    with open(credential_file, "wb") as file:
        file.write(encrypted_value)
    
    print(f"Credential '{name}' stored in vault '{vault}'")

def retrieve_credential(name, vault="default"):
    """Retrieve a credential"""
    # Load config
    if not CONFIG_FILE.exists():
        print("Configuration file not found. Initialize the store first.")
        return None
        
    with open(CONFIG_FILE, "r") as file:
        config = json.load(file)
    
    if vault not in config["credentials"] or name not in config["credentials"][vault]:
        print(f"Credential '{name}' not found in vault '{vault}'")
        return None
    
    # Get credential ID
    credential_id = config["credentials"][vault][name]["id"]
    credential_file = CREDENTIALS_DIR / f"{credential_id}.enc"
    
    if not credential_file.exists():
        print(f"Credential file for '{name}' not found")
        return None
    
    # Decrypt
    key = get_encryption_key()
    fernet = Fernet(key)
    with open(credential_file, "rb") as file:
        encrypted_value = file.read()
    
    try:
        decrypted_value = fernet.decrypt(encrypted_value).decode()
        return decrypted_value
    except Exception as e:
        print(f"Error decrypting credential: {str(e)}")
        return None

def list_credentials(vault="default"):
    """List all credentials in a vault"""
    if not CONFIG_FILE.exists():
        print("Configuration file not found. Initialize the store first.")
        return
        
    with open(CONFIG_FILE, "r") as file:
        config = json.load(file)
    
    if vault not in config["credentials"]:
        print(f"Vault '{vault}' not found")
        return
    
    print(f"Credentials in vault '{vault}':")
    for name in config["credentials"][vault]:
        created = config["credentials"][vault][name]["created"]
        print(f"  - {name} (created: {created})")

def update_mcp_config():
    """Update MCP configuration with secure credentials"""
    mcp_config_path = Path(".cursor/mcp.json")
    if not mcp_config_path.exists():
        print("MCP configuration file not found")
        return
    
    # Load config
    with open(mcp_config_path, "r") as file:
        config = json.load(file)
    
    # Process Brave Search
    if "braveSearch" in config["mcpServer"] and config["mcpServer"]["braveSearch"]["enabled"]:
        brave_key = retrieve_credential("BRAVE_SEARCH_API_KEY")
        if brave_key:
            config["mcpServer"]["braveSearch"]["configuration"]["apiKey"] = brave_key
            print("Updated Brave Search API key")
    
    # Process Tavily
    if "tavily" in config["mcpServer"] and config["mcpServer"]["tavily"]["enabled"]:
        tavily_key = retrieve_credential("TAVILY_API_KEY")
        if tavily_key:
            config["mcpServer"]["tavily"]["configuration"]["apiKey"] = tavily_key
            print("Updated Tavily API key")
    
    # Save updated config
    with open(mcp_config_path, "w") as file:
        json.dump(config, file, indent=2)
    
    print("MCP configuration updated with secure credentials")

def main():
    """Main function"""
    parser = argparse.ArgumentParser(description="Secure credential management for Ages of Arda")
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")
    
    # Initialize command
    init_parser = subparsers.add_parser("init", help="Initialize credential store")
    
    # Store command
    store_parser = subparsers.add_parser("store", help="Store a credential")
    store_parser.add_argument("name", help="Credential name")
    store_parser.add_argument("--value", help="Credential value (omit to input securely)")
    store_parser.add_argument("--vault", default="default", help="Vault name")
    
    # Retrieve command
    retrieve_parser = subparsers.add_parser("retrieve", help="Retrieve a credential")
    retrieve_parser.add_argument("name", help="Credential name")
    retrieve_parser.add_argument("--vault", default="default", help="Vault name")
    
    # List command
    list_parser = subparsers.add_parser("list", help="List credentials")
    list_parser.add_argument("--vault", default="default", help="Vault name")
    
    # Update MCP config command
    update_parser = subparsers.add_parser("update-mcp", help="Update MCP configuration")
    
    args = parser.parse_args()
    
    if args.command == "init":
        initialize_store()
    elif args.command == "store":
        value = args.value if args.value else getpass(f"Enter value for '{args.name}': ")
        store_credential(args.name, value, args.vault)
    elif args.command == "retrieve":
        value = retrieve_credential(args.name, args.vault)
        if value:
            print(f"{args.name}: {value}")
    elif args.command == "list":
        list_credentials(args.vault)
    elif args.command == "update-mcp":
        update_mcp_config()
    else:
        parser.print_help()

if __name__ == "__main__":
    main() 