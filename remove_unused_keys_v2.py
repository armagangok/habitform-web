#!/usr/bin/env python3
"""
Script to remove unused translation keys from the JSON file.
This version is more careful and only removes keys that are truly unused.
"""

import json
import re
import os

def load_unused_keys():
    """Load the list of unused keys from the file."""
    unused_keys = set()
    try:
        with open('unused_translation_keys.txt', 'r') as f:
            for line in f:
                key = line.strip()
                if key:
                    unused_keys.add(key)
    except FileNotFoundError:
        print("Error: unused_translation_keys.txt not found. Run analyze_translations.py first.")
        return set()
    return unused_keys

def load_locale_keys_mapping():
    """Load the mapping from LocaleKeys file."""
    locale_keys_file = 'lib/features/translation/constants/locale_keys.g.dart'
    key_mapping = {}
    
    try:
        with open(locale_keys_file, 'r', encoding='utf-8') as f:
            content = f.read()
            # Pattern to match: static const KEY_NAME = 'json.path';
            pattern = r"static const ([a-zA-Z_][a-zA-Z0-9_]*) = '([^']+)';"
            matches = re.findall(pattern, content)
            for key_name, json_path in matches:
                key_mapping[json_path] = key_name
    except Exception as e:
        print(f"Error reading LocaleKeys file: {e}")
        return {}
    
    return key_mapping

def remove_key_from_dict(data, key_path):
    """Remove a key from a nested dictionary using dot notation."""
    parts = key_path.split('.')
    current = data
    
    # Navigate to the parent of the key to remove
    for part in parts[:-1]:
        if part in current and isinstance(current[part], dict):
            current = current[part]
        else:
            return False  # Key path doesn't exist
    
    # Remove the final key
    final_key = parts[-1]
    if final_key in current:
        del current[final_key]
        return True
    return False

def clean_empty_objects(data):
    """Remove empty objects from the dictionary."""
    if isinstance(data, dict):
        # First, clean all nested objects
        for key in list(data.keys()):
            if isinstance(data[key], dict):
                clean_empty_objects(data[key])
                # Remove empty objects
                if not data[key]:
                    del data[key]
    return data

def main():
    print("🗑️  Removing unused translation keys (v2)...")
    
    # Load unused keys
    unused_keys = load_unused_keys()
    if not unused_keys:
        print("No unused keys to remove.")
        return
    
    # Load LocaleKeys mapping to double-check
    locale_keys_mapping = load_locale_keys_mapping()
    
    # Filter out keys that are still in LocaleKeys (safety check)
    safe_to_remove = set()
    for key in unused_keys:
        if key not in locale_keys_mapping:
            safe_to_remove.add(key)
        else:
            print(f"⚠️  Skipping {key} - still referenced in LocaleKeys")
    
    print(f"Found {len(safe_to_remove)} safe keys to remove (out of {len(unused_keys)} unused keys)")
    
    # Load the JSON file
    json_file = 'assets/translations/en-US.json'
    try:
        with open(json_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error loading JSON file: {e}")
        return
    
    # Count keys before removal
    def count_keys(obj, prefix=''):
        count = 0
        if isinstance(obj, dict):
            for key, value in obj.items():
                current_key = f"{prefix}.{key}" if prefix else key
                if isinstance(value, dict):
                    count += count_keys(value, current_key)
                else:
                    count += 1
        return count
    
    initial_count = count_keys(data)
    print(f"Initial key count: {initial_count}")
    
    # Remove unused keys
    removed_count = 0
    for key_path in safe_to_remove:
        if remove_key_from_dict(data, key_path):
            removed_count += 1
        else:
            print(f"Warning: Could not remove key '{key_path}' - not found")
    
    # Clean up empty objects
    data = clean_empty_objects(data)
    
    # Count keys after removal
    final_count = count_keys(data)
    print(f"Final key count: {final_count}")
    print(f"Removed {removed_count} keys")
    
    # Create backup
    backup_file = json_file + '.backup'
    try:
        with open(backup_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
        print(f"✅ Backup created: {backup_file}")
    except Exception as e:
        print(f"Error creating backup: {e}")
        return
    
    # Write the cleaned JSON
    try:
        with open(json_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=4, ensure_ascii=False)
        print(f"✅ Updated {json_file}")
    except Exception as e:
        print(f"Error writing JSON file: {e}")
        return
    
    print(f"\n🎉 Optimization complete!")
    print(f"Removed {removed_count} unused keys")
    print(f"Reduced file size from {initial_count} to {final_count} keys")

if __name__ == "__main__":
    main()
