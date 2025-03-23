#!/usr/bin/env python3
"""
Checks for conflicts between cursor rules
"""

import os
import sys
import yaml
import json
from pathlib import Path

def extract_rule_metadata(file_path):
    """Extract metadata from a rule file"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if not content.startswith('---'):
        return None
    
    try:
        _, frontmatter, _ = content.split('---', 2)
        metadata = yaml.safe_load(frontmatter)
        metadata['file_path'] = str(file_path)
        return metadata
    except Exception:
        return None

def check_for_conflicts(rules):
    """Check for conflicts between rules"""
    conflicts = []
    
    # Group rules by glob pattern
    rules_by_glob = {}
    for rule in rules:
        glob = rule.get('glob', '')
        if glob:
            if glob not in rules_by_glob:
                rules_by_glob[glob] = []
            rules_by_glob[glob].append(rule)
    
    # Check for priority conflicts
    for glob, glob_rules in rules_by_glob.items():
        if len(glob_rules) <= 1:
            continue
        
        # Sort by priority
        glob_rules.sort(key=lambda r: r.get('priority', 0), reverse=True)
        
        # Check for close priorities
        for i in range(len(glob_rules) - 1):
            rule1 = glob_rules[i]
            rule2 = glob_rules[i + 1]
            priority1 = rule1.get('priority', 0)
            priority2 = rule2.get('priority', 0)
            
            if abs(priority1 - priority2) < 50:
                conflicts.append({
                    'type': 'priority',
                    'glob': glob,
                    'rule1': rule1,
                    'rule2': rule2,
                    'message': f"Priority conflict: {rule1['file_path']} ({priority1}) and {rule2['file_path']} ({priority2}) have similar priorities for the same glob pattern"
                })
    
    return conflicts

def main():
    # Using Path for cross-platform compatibility
    rules_dir = Path('.cursor/rules')
    if not rules_dir.exists():
        print(f"Rules directory not found: {rules_dir}")
        sys.exit(1)
    
    rule_files = list(rules_dir.glob('**/*.mdc'))
    if not rule_files:
        print("No rule files found")
        sys.exit(0)
    
    # Extract metadata
    rules = []
    for file in rule_files:
        metadata = extract_rule_metadata(file)
        if metadata:
            rules.append(metadata)
    
    print(f"Loaded {len(rules)} rules for conflict detection")
    
    # Check for conflicts
    conflicts = check_for_conflicts(rules)
    
    if conflicts:
        print(f"Found {len(conflicts)} potential conflicts:")
        for i, conflict in enumerate(conflicts, 1):
            print(f"Conflict {i}: {conflict['message']}")
        sys.exit(1)
    else:
        print("No rule conflicts detected")
        sys.exit(0)

if __name__ == '__main__':
    main()