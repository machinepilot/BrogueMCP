#!/usr/bin/env python3
"""
Validates cursor rule files for correct format and metadata
"""

import os
import sys
import argparse
import yaml
import json
from pathlib import Path

def validate_rule_file(file_path):
    """Validate a single rule file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check for frontmatter
        if not content.startswith('---'):
            return (False, f"Missing frontmatter in {file_path}")
        
        # Extract frontmatter
        _, frontmatter, _ = content.split('---', 2)
        
        # Parse frontmatter
        try:
            metadata = yaml.safe_load(frontmatter)
        except yaml.YAMLError as e:
            return (False, f"Invalid YAML in frontmatter: {e}")
        
        # Check required fields
        required_fields = ['title', 'glob', 'priority']
        missing_fields = [field for field in required_fields if field not in metadata]
        
        if missing_fields:
            return (False, f"Missing required fields in frontmatter: {', '.join(missing_fields)}")
        
        # Check recommended fields
        recommended_fields = ['description']
        missing_recommended = [field for field in recommended_fields if field not in metadata]
        
        if missing_recommended:
            return (True, f"Warning: Missing recommended fields: {', '.join(missing_recommended)}")
            
        return (True, "Valid rule file")
    except Exception as e:
        return (False, f"Error validating {file_path}: {str(e)}")

def main():
    parser = argparse.ArgumentParser(description='Validate cursor rule files')
    parser.add_argument('--ci', action='store_true', help='Run in CI mode (exit code on failures)')
    args = parser.parse_args()
    
    # Using Path for cross-platform compatibility
    rules_dir = Path('.cursor/rules')
    if not rules_dir.exists():
        print(f"Rules directory not found: {rules_dir}")
        sys.exit(1)
    
    rule_files = list(rules_dir.glob('**/*.mdc'))
    if not rule_files:
        print("No rule files found")
        sys.exit(1)
    
    print(f"Found {len(rule_files)} rule files to validate")
    
    results = []
    for file in rule_files:
        valid, message = validate_rule_file(file)
        results.append({
            'file': str(file),
            'valid': valid,
            'message': message
        })
        
        status = "✅" if valid else "❌"
        print(f"{status} {file}: {message}")
    
    invalid_count = sum(1 for r in results if not r['valid'])
    warning_count = sum(1 for r in results if r['valid'] and r['message'].startswith('Warning'))
    
    print(f"\nValidation complete: {len(results)} files checked, {invalid_count} invalid, {warning_count} warnings")
    
    if args.ci and invalid_count > 0:
        sys.exit(1)

if __name__ == '__main__':
    main()
