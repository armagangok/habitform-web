#!/usr/bin/env python3
"""
Script to analyze translation key usage in the Flutter project.
This script will identify unused translation keys that can be safely removed.
"""

import json
import re
import os
from pathlib import Path

def extract_locale_keys_from_code():
    """Extract all LocaleKeys usage from Dart files."""
    used_keys = set()
    
    # First, read the LocaleKeys file to get the mapping
    locale_keys_file = 'lib/features/translation/constants/locale_keys.g.dart'
    key_mapping = {}
    
    try:
        with open(locale_keys_file, 'r', encoding='utf-8') as f:
            content = f.read()
            # Pattern to match: static const KEY_NAME = 'json.path';
            pattern = r"static const ([a-zA-Z_][a-zA-Z0-9_]*) = '([^']+)';"
            matches = re.findall(pattern, content)
            for key_name, json_path in matches:
                key_mapping[key_name] = json_path
    except Exception as e:
        print(f"Error reading LocaleKeys file: {e}")
        return set()
    
    # Search for LocaleKeys. usage in all Dart files
    dart_files = []
    for root, dirs, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    
    # Pattern to match LocaleKeys.KEY_NAME
    pattern = r'LocaleKeys\.([a-zA-Z_][a-zA-Z0-9_]*)'
    
    for file_path in dart_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                matches = re.findall(pattern, content)
                for match in matches:
                    if match in key_mapping:
                        used_keys.add(key_mapping[match])
        except Exception as e:
            print(f"Error reading {file_path}: {e}")
    
    return used_keys

def load_translation_keys(json_file):
    """Load all translation keys from the JSON file."""
    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    def extract_keys(obj, prefix=''):
        keys = set()
        if isinstance(obj, dict):
            for key, value in obj.items():
                current_key = f"{prefix}.{key}" if prefix else key
                if isinstance(value, dict):
                    keys.update(extract_keys(value, current_key))
                else:
                    keys.add(current_key)
        return keys
    
    return extract_keys(data)

def main():
    print("🔍 Analyzing translation key usage...")
    
    # Load LocaleKeys mapping first
    locale_keys_file = 'lib/features/translation/constants/locale_keys.g.dart'
    locale_keys_mapping = {}
    
    try:
        with open(locale_keys_file, 'r', encoding='utf-8') as f:
            content = f.read()
            # Pattern to match: static const KEY_NAME = 'json.path';
            pattern = r"static const ([a-zA-Z_][a-zA-Z0-9_]*) = '([^']+)';"
            matches = re.findall(pattern, content)
            for key_name, json_path in matches:
                locale_keys_mapping[json_path] = key_name
        print(f"Found {len(locale_keys_mapping)} keys in LocaleKeys file")
    except Exception as e:
        print(f"Error reading LocaleKeys file: {e}")
        return set()
    
    # Extract used keys from code
    used_json_keys = extract_locale_keys_from_code()
    print(f"Found {len(used_json_keys)} LocaleKeys used in code")
    
    # Load all keys from JSON
    json_file = 'assets/translations/en-US.json'
    all_json_keys = load_translation_keys(json_file)
    print(f"Found {len(all_json_keys)} keys in JSON file")
    
    # Find unused keys - only those that are in JSON but not in LocaleKeys at all
    unused_keys = all_json_keys - set(locale_keys_mapping.keys())
    
    print(f"\n📊 Analysis Results:")
    print(f"Total keys in JSON: {len(all_json_keys)}")
    print(f"Keys used in code: {len(used_json_keys)}")
    print(f"Unused keys: {len(unused_keys)}")
    
    if unused_keys:
        print(f"\n🗑️  Unused keys that can be removed:")
        for key in sorted(unused_keys):
            print(f"  - {key}")
        
        # Save unused keys to file for reference
        with open('unused_translation_keys.txt', 'w') as f:
            for key in sorted(unused_keys):
                f.write(f"{key}\n")
        print(f"\n💾 Unused keys saved to 'unused_translation_keys.txt'")
    else:
        print("\n✅ All translation keys are being used!")
    
    return unused_keys

if __name__ == "__main__":
    main()
