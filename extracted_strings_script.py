import os
import re
import json
import sys

# General patterns for UI elements
PATTERNS = [
    re.compile(r"Text\s*\(\s*['\"]([^'\"]+)['\"]\s*(?:,[^)]*)?\)", re.IGNORECASE),
    re.compile(r"TextSpan\s*\(\s*text:\s*['\"]([^'\"]+)['\"]\s*(?:,[^)]*)?\)", re.IGNORECASE),
    re.compile(r"SnackBar\s*\(\s*content:\s*(?:Text\s*\(\s*)?['\"]([^'\"]+)['\"](?:\s*\))?\s*(?:,[^)]*)?\)", re.IGNORECASE),
    re.compile(r"AlertDialog\s*\((?:[^)]*title:\s*(?:Text\s*\(\s*)?['\"]([^'\"]+)['\"](?:\s*\))?|[^)]*content:\s*(?:Text\s*\(\s*)?['\"]([^'\"]+)['\"](?:\s*\))?)(?:,[^)]*)?\)", re.IGNORECASE),
    re.compile(r"SimpleDialogOption\s*\((?:[^)]*child:\s*(?:Text\s*\(\s*)?)?['\"]([^'\"]+)['\"](?:\s*\))?(?:,[^)]*)?\)", re.IGNORECASE),
    re.compile(r"Tooltip\s*\(\s*message:\s*['\"]([^'\"]+)['\"]\s*(?:,[^)]*)?\)", re.IGNORECASE),
    re.compile(r"Chip\s*\((?:[^)]*label:\s*(?:Text\s*\(\s*)?)?['\"]([^'\"]+)['\"](?:\s*\))?(?:,[^)]*)?\)", re.IGNORECASE),
    re.compile(r"DropdownButtonFormField\s*\((?:[^)]*hint:\s*(?:Text\s*\(\s*)?)?['\"]([^'\"]+)['\"](?:\s*\))?(?:,[^)]*)?\)", re.IGNORECASE),
    re.compile(r"InputDecoration\s*\((?:[^)]*labelText:\s*['\"]([^'\"]+)['\"]|[^)]*helperText:\s*['\"]([^'\"]+)['\"]|[^)]*hintText:\s*['\"]([^'\"]+)['\"])(?:,[^)]*)?\)", re.IGNORECASE),
    re.compile(r"(?:ElevatedButton|TextButton|OutlinedButton)\s*\((?:[^)]*child:\s*(?:Text\s*\(\s*)?)?['\"]([^'\"]+)['\"](?:\s*\))?(?:,[^)]*)?\)", re.IGNORECASE),
    re.compile(r"(?:showDialog|showModalBottomSheet)\s*\((?:[^)]*builder:\s*\([^)]*\)\s*=>\s*(?:[^;]*Text\s*\(\s*['\"]([^'\"]+)['\"]\)|[^;]*SimpleDialogOption\s*\(\s*child:\s*Text\s*\(\s*['\"]([^'\"]+)['\"]\))|[^)]*title:\s*(?:Text\s*\(\s*)?['\"]([^'\"]+)['\"](?:\s*\))?|[^)]*content:\s*(?:Text\s*\(\s*)?['\"]([^'\"]+)['\"](?:\s*\))?)(?:[^;]*?\);)", re.IGNORECASE),
    re.compile(r"ScaffoldMessenger\s*\.\s*of\s*\([^)]*\)\s*\.\s*showSnackBar\s*\(\s*SnackBar\s*\(\s*content:\s*(?:Text\s*\(\s*)?['\"]([^'\"]+)['\"](?:\s*\))?", re.IGNORECASE),
]

PREFERENCE_PATTERNS = [
    re.compile(r"title:\s*['\"]([^'\"]+)['\"]", re.IGNORECASE),
    re.compile(r"description:\s*['\"]([^'\"]+)['\"]", re.IGNORECASE),
    re.compile(r"dialogTitle:\s*['\"]([^'\"]+)['\"]", re.IGNORECASE),
    re.compile(r"summary:\s*['\"]([^'\"]+)['\"]", re.IGNORECASE),
    re.compile(r"\w+Preference\s*\((?:[^)]*title:\s*['\"]([^'\"]+)['\"]|[^)]*description:\s*['\"]([^'\"]+)['\"])(?:,[^)]*)?\)", re.IGNORECASE),
]

EXCLUDED_FILES = ["lib/i18n/strings.g.dart", "lib/i18n/strings_en.g.dart"]
APP_ROOT = "/app/" # Assuming script runs from repo root or this path is adjusted

results = []
file_list = []

# Attempt to read file_list.txt from the current directory or APP_ROOT
# This makes the script more robust to where it's executed from within the repo.
potential_list_paths = ["file_list.txt", os.path.join(APP_ROOT, "file_list.txt")]
list_path_found = None
for path_option in potential_list_paths:
    if os.path.exists(path_option):
        list_path_found = path_option
        break

if not list_path_found:
    print("Critical Error: file_list.txt not found in expected locations. This file is essential for operation.", file=sys.stderr)
    sys.exit(1)

try:
    with open(list_path_found, "r", encoding="utf-8") as f:
        file_list = [line.strip() for line in f if line.strip().endswith(".dart")]
except FileNotFoundError: # Should be caught by check above, but as a safeguard.
    print(f"Critical Error: file_list.txt not found at {list_path_found}.", file=sys.stderr)
    sys.exit(1)


def is_likely_user_facing(s_literal):
    if not s_literal or not isinstance(s_literal, str):
        return False
    s_literal = s_literal.strip()
    if not s_literal: # Empty or whitespace only strings are not user-facing.
        return False

    if len(s_literal) < 2 and s_literal not in ["?", "!", "%", "+", "-", "*", "#", "@", "&", "<", ">", "OK", "No", "Yes", "Go", "Up", "On", "Of"]: # Expanded list of short allowed strings
        return False

    if s_literal.startswith("pref_") or s_literal.startswith("key_") or \
       s_literal.startswith("debug_") or s_literal.startswith("log_") or s_literal.startswith("err_") or \
       s_literal.startswith("val_") or s_literal.startswith("id_"):
        return False
    if re.match(r"^[A-Z0-9_]+$", s_literal) and len(s_literal.split('_')) > 1 and s_literal.isupper(): # SCREAMING_SNAKE_CASE
        return False

    if "@" in s_literal and not " " in s_literal and "." in s_literal :
         if not s_literal.startswith("@"):
            return False
    if (s_literal.startswith("http:") or s_literal.startswith("https:")) and " " not in s_literal:
        return False

    if "/" in s_literal and not " " in s_literal and "." in s_literal:
         if s_literal.count('/') + s_literal.count('.') > 2 and len(s_literal) > 10:
            if not (s_literal.startswith("./") or s_literal.startswith("../")):
                 return False

    if re.match(r"^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$", s_literal):
        return False

    if any(kw in s_literal for kw in ["=>", "&&", "||", "dart:", "package:"]) and len(s_literal.split()) > 2 :
        return False
    if (s_literal.lower().startswith("error:")) or (s_literal.lower().startswith("exception:")):
        if len(s_literal.split()) > 2 or ":" in s_literal[s_literal.lower().find("error:")+6:]:
            return False

    if re.match(r"<[^>]+>", s_literal) and not " " in s_literal and len(s_literal) > 3:
        return False

    if s_literal in ["...", "N/A", "--", "----", "(empty)", "(none)"]:
        return True

    if len(re.findall(r"[(){}\[\];<>|=/\\]", s_literal)) > 3 and len(s_literal) < 30 :
        if not any (ui_kw in s_literal.lower() for ui_kw in ['select', 'option', 'setting', 'value', 'field', 'name', 'type', 'date', 'time', 'format', 'unit', 'result', 'code']):
            return False

    if len(s_literal) > 30 and " " not in s_literal and "_" not in s_literal and "-" not in s_literal:
        has_lower = any('a' <= char <= 'z' for char in s_literal)
        has_upper = any('A' <= char <= 'Z' for char in s_literal)
        if has_lower and has_upper and not any(num_char.isdigit() for num_char in s_literal) : # CamelCase/PascalCase without numbers
            return False

    if s_literal.endswith((".csv", ".json", ".fit", ".tcx", ".db", ".log", ".tmp", ".bak", ".zip", ".png", ".jpg", ".svg")) and not " " in s_literal:
        return False

    if s_literal.isdigit() or (s_literal.startswith("-") and s_literal[1:].isdigit()):
        return False
    if re.match(r"^[0-9.,:\-]+$",s_literal) and (s_literal.count(".") <= 2 and s_literal.count(",") <= 1 and s_literal.count(":") <= 2 and s_literal.count("-") <=2 ):
        if len(s_literal) < 10 or s_literal.count(':') > 0 : # Allow short version-like numbers or time
             pass
        else:
             return False

    return True

def process_string_literal(literal, filepath, line_num):
    original_literal = literal

    processed_literal = re.sub(r"\$\{([^}]+)\}", r"{\1}", literal)
    processed_literal = re.sub(r"\$([a-zA-Z_][a-zA-Z0-9_]*)", r"{\1}", processed_literal)

    if ' + ' in literal:
        parts = literal.split('+')
        parts = [p.strip() for p in parts if p.strip()]

        if len(parts) > 1:
            new_string_parts = []
            for i, part in enumerate(parts):
                part = part.strip()
                if (part.startswith("'") and part.endswith("'")) or \
                   (part.startswith('"') and part.endswith('"')):
                    new_string_parts.append(part[1:-1])
                else:
                    var_name = re.sub(r"[^a-zA-Z0-9_]", "", part.split('.')[0])
                    if not var_name or var_name.isdigit(): var_name = "value"
                    new_string_parts.append(f"{{{var_name}}}")

            final_concat_string = ""
            for i, p_part in enumerate(new_string_parts):
                final_concat_string += p_part
            processed_literal = final_concat_string

    if is_likely_user_facing(processed_literal):
        if r'\n' in processed_literal:
            lines = processed_literal.split(r'\n')
            final_str = r'\n'.join(line.strip() for line in lines)
        else:
            final_str = ' '.join(processed_literal.split())
        return final_str.strip()

    original_with_placeholders = re.sub(r"\$\{([^}]+)\}", r"{\1}", original_literal)
    original_with_placeholders = re.sub(r"\$([a-zA-Z_][a-zA-Z0-9_]*)", r"{\1}", original_with_placeholders)
    if is_likely_user_facing(original_with_placeholders):
        if r'\n' in original_with_placeholders:
            lines = original_with_placeholders.split(r'\n')
            final_str = r'\n'.join(line.strip() for line in lines)
        else:
            final_str = ' '.join(original_with_placeholders.split())
        return final_str.strip()

    return None

# Main processing loop
for filepath_short in file_list:
    # Construct full path relative to where the script *might* be if APP_ROOT is /app
    # However, if file_list.txt was found at "./file_list.txt", then paths in it are relative to "."
    # So, paths in file_list.txt are assumed to be like "lib/..."
    # And the script needs to prepend "/app/" to them to access them in the tool's FS.
    filepath_full = os.path.join(APP_ROOT, filepath_short)

    if filepath_short in EXCLUDED_FILES or filepath_short.endswith(".g.dart"):
        continue

    try:
        with open(filepath_full, "r", encoding="utf-8") as f:
            content_lines = f.readlines()
    except FileNotFoundError:
        # This means the path construction or file_list.txt content is problematic.
        # print(f"Warning: File not found (and skipped): {filepath_full}", file=sys.stderr)
        continue
    except Exception as e:
        # print(f"Warning: Error reading file {filepath_full}: {e}", file=sys.stderr)
        continue

    current_patterns_for_file = PATTERNS
    if filepath_short.startswith("lib/preferences/"):
        current_patterns_for_file = PATTERNS + PREFERENCE_PATTERNS

    for line_num, line_content in enumerate(content_lines, 1):
        stripped_line = line_content.strip()
        if stripped_line.startswith("//") or stripped_line.startswith("/*") or stripped_line.endswith("*/") or stripped_line.startswith("*"):
            continue

        log_print_pattern = r"\b(print|debugPrint|log\.(?:v|d|i|w|e|wtf|f|s))\s*\("
        if re.search(log_print_pattern, stripped_line):
            is_genuinely_a_log_call = True
            for ui_pattern_check in current_patterns_for_file:
                for match_ui in ui_pattern_check.finditer(line_content):
                    for group_idx in range(1, ui_pattern_check.groups + 1):
                        ui_string_content = match_ui.group(group_idx)
                        if ui_string_content and re.search(log_print_pattern, ui_string_content):
                            is_genuinely_a_log_call = False; break
                    if not is_genuinely_a_log_call: break
                if not is_genuinely_a_log_call: break
            if is_genuinely_a_log_call:
                continue

        if stripped_line.startswith("assert("):
            continue

        for pattern in current_patterns_for_file:
            try:
                for match in pattern.finditer(line_content):
                    for i in range(1, pattern.groups + 1):
                        string_literal_match = match.group(i)
                        if string_literal_match:
                            final_string = process_string_literal(string_literal_match, filepath_short, line_num)
                            if final_string:
                                results.append({"string": final_string, "file": filepath_short, "line": line_num})
            except re.error:
                pass

unique_results_by_location = []
seen_locations_set = set()
for item in results:
    location_tuple = (item["string"], item["file"], item["line"])
    if location_tuple not in seen_locations_set:
        unique_results_by_location.append(item)
        seen_locations_set.add(location_tuple)

final_unique_results_list = []
seen_strings_set = set()
for item in unique_results_by_location:
    normalized_string = item["string"].strip()
    if not normalized_string:
        continue

    if normalized_string not in seen_strings_set:
        final_unique_results_list.append({"string": normalized_string, "file": item["file"], "line": item["line"]})
        seen_strings_set.add(normalized_string)

print(json.dumps(final_unique_results_list, indent=2))
```
