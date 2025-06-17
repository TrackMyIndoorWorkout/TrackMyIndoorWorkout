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
APP_ROOT = "/app/"

results = []
file_list = []

try:
    with open("file_list.txt", "r", encoding="utf-8") as f:
        file_list = [line.strip() for line in f if line.strip().endswith(".dart")]
except FileNotFoundError:
    # This should not happen if Turn 3 was successful.
    print("Critical Error: file_list.txt not found. This file is essential for operation.", file=sys.stderr)
    sys.exit(1)

def is_likely_user_facing(s_literal):
    if not s_literal or not isinstance(s_literal, str):
        return False
    s_literal = s_literal.strip()
    if not s_literal: # Empty or whitespace only strings are not user-facing.
        return False

    # Allow very short strings if they are common symbols or affirmative/negative.
    if len(s_literal) < 2 and s_literal not in ["?", "!", "%", "+", "-", "*", "#", "@", "&", "<", ">", "OK", "No", "Yes"]:
        return False

    # Filter out typical programming/key identifiers
    if s_literal.startswith("pref_") or s_literal.startswith("key_") or \
       s_literal.startswith("debug_") or s_literal.startswith("log_") or s_literal.startswith("err_"):
        return False
    if re.match(r"^[A-Z0-9_]+$", s_literal) and len(s_literal.split('_')) > 1 and s_literal.isupper(): # SCREAMING_SNAKE_CASE
        return False

    # Filter out email addresses and URLs
    if "@" in s_literal and not " " in s_literal and "." in s_literal : # Basic email check
         if not s_literal.startswith("@"): # Allow if it's like an @mention
            return False
    if (s_literal.startswith("http:") or s_literal.startswith("https:")) and " " not in s_literal:
        return False

    # Filter out file paths and complex path-like strings
    if "/" in s_literal and not " " in s_literal and "." in s_literal: # Contains / and . without spaces
         # More lenient: allow if it's short and might be e.g. "image/png" or "v1.0/data"
         if s_literal.count('/') + s_literal.count('.') > 2 and len(s_literal) > 10: # If many separators or long
            if not (s_literal.startswith("./") or s_literal.startswith("../")): # Allow simple relative paths
                 return False

    if re.match(r"^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$", s_literal): # Hex color codes
        return False

    # Filter out code-like constructs or developer messages
    if any(kw in s_literal for kw in ["=>", "&&", "||", "dart:", "package:"]) and len(s_literal.split()) > 2 :
        return False
    if (s_literal.lower().startswith("error:")) or (s_literal.lower().startswith("exception:")):
        if len(s_literal.split()) > 2 or ":" in s_literal[s_literal.lower().find("error:")+6:]: # More than 2 words or has details after "Error:"
            return False

    if re.match(r"<[^>]+>", s_literal) and not " " in s_literal and len(s_literal) > 3: # HTML/XML tags
        return False

    # Specific known non-UI strings (can be expanded)
    if s_literal in ["...", "N/A", "--", "----", "(empty)"]:
        return True # These are often intentional UI placeholders

    # Filter strings with many programming symbols or unusual characters for UI
    if len(re.findall(r"[(){}\[\];<>|=/\\]", s_literal)) > 3 and len(s_literal) < 30 :
        # Avoid filtering if common UI related keywords are present
        if not any (ui_kw in s_literal.lower() for ui_kw in ['select', 'option', 'setting', 'value', 'field', 'name', 'type', 'date', 'time']):
            return False

    # Filter long strings without spaces (likely identifiers, class names, etc.)
    if len(s_literal) > 30 and " " not in s_literal and "_" not in s_literal and "-" not in s_literal:
        has_lower = any('a' <= char <= 'z' for char in s_literal)
        has_upper = any('A' <= char <= 'Z' for char in s_literal)
        if has_lower and has_upper: # CamelCase or PascalCase likely class/method name
            return False

    # Filter out common file extensions or specific file names if they stand alone
    if s_literal.endswith((".csv", ".json", ".fit", ".tcx", ".db", ".log", ".tmp", ".bak")) and not " " in s_literal:
        return False

    # Filter out pure numbers, possibly with limited punctuation (version numbers, ranges)
    if s_literal.isdigit() or (s_literal.startswith("-") and s_literal[1:].isdigit()):
        return False
    # Allows "1.0", "1,000", "1.0.0", but not "1.2.3.4.5"
    if re.match(r"^[0-9.,:\-]+$",s_literal) and (s_literal.count(".") <= 2 and s_literal.count(",") <= 1 and s_literal.count(":") <= 2 and s_literal.count("-") <=2 ):
        if len(s_literal) < 10: # Allow short version-like numbers
             pass
        else: # If long and only numbers/punctuation, likely not UI
             return False

    return True

def process_string_literal(literal, filepath, line_num):
    original_literal = literal

    # 1. Convert Dart interpolations to generic placeholders like {variableName}
    processed_literal = re.sub(r"\$\{([^}]+)\}", r"{\1}", literal)
    processed_literal = re.sub(r"\$([a-zA-Z_][a-zA-Z0-9_]*)", r"{\1}", processed_literal)

    # 2. Handle concatenations: 'String1 ' + var + ' String2'
    if ' + ' in literal:
        # Split by ' + ' to analyze parts. This is a simplified AST-like approach.
        parts = literal.split('+')
        # Filter out empty strings that might result from splitting if ' + ' is at start/end
        parts = [p.strip() for p in parts if p.strip()]

        # If only one part after split (e.g. " 'string' "), it's not a concatenation to process here.
        if len(parts) > 1:
            new_string_parts = []
            for i, part in enumerate(parts):
                part = part.strip()
                # Check if the part is a string literal '...' or "..."
                if (part.startswith("'") and part.endswith("'")) or \
                   (part.startswith('"') and part.endswith('"')):
                    new_string_parts.append(part[1:-1]) # Add the content of the literal
                else:
                    # It's a variable or expression. Create a placeholder.
                    # Try to make a somewhat meaningful placeholder from the variable name.
                    var_name = re.sub(r"[^a-zA-Z0-9_]", "", part.split('.')[0]) # Basic sanitization
                    if not var_name or var_name.isdigit(): var_name = "value" # Default placeholder
                    new_string_parts.append(f"{{{var_name}}}")

            # Join the processed parts. Logic for adding spaces:
            # Add a space if two non-empty literal parts are joined,
            # or if a literal is joined with a placeholder, unless the literal already ends with a space.
            # Placeholders are assumed to need spaces around them if not adjacent to existing space.
            final_concat_string = ""
            for i, p_part in enumerate(new_string_parts):
                final_concat_string += p_part
                if i < len(new_string_parts) - 1: # If not the last part
                    # Add space if current part doesn't end with space AND next part doesn't start with space
                    # AND current part is not a placeholder that might be better without a trailing space (e.g. "{val}%")
                    # This spacing logic for concatenation is tricky.
                    # A simpler approach might be to just join with space and let translators adjust.
                    # For now, join directly, and rely on normalization later.
                    pass # Will be handled by whitespace normalization later if needed
            processed_literal = final_concat_string

    # 3. Apply heuristic filtering and whitespace normalization
    if is_likely_user_facing(processed_literal):
        # Normalize whitespace: multiple spaces to one, strip leading/trailing.
        # Preserve newline characters if they seem intentional (e.g. r'\n').
        if r'\n' in processed_literal: # Check for literal '\n' characters
            lines = processed_literal.split(r'\n')
            # Strip spaces from each line, but keep the \n structure
            final_str = r'\n'.join(line.strip() for line in lines)
        else:
            # No explicit \n, so collapse all whitespace to single spaces
            final_str = ' '.join(processed_literal.split())

        return final_str.strip() # Final strip for the whole string

    # 4. Fallback: If processed_literal is rejected, try original_literal (with placeholders)
    # This can happen if concatenation processing results in something too fragmented.
    original_with_placeholders = re.sub(r"\$\{([^}]+)\}", r"{\1}", original_literal)
    original_with_placeholders = re.sub(r"\$([a-zA-Z_][a-zA-Z0-9_]*)", r"{\1}", original_with_placeholders)
    if is_likely_user_facing(original_with_placeholders):
        if r'\n' in original_with_placeholders:
            lines = original_with_placeholders.split(r'\n')
            final_str = r'\n'.join(line.strip() for line in lines)
        else:
            final_str = ' '.join(original_with_placeholders.split())
        return final_str.strip()

    return None # If neither version is deemed user-facing

# Main processing loop
for filepath_short in file_list:
    filepath_full = os.path.join(APP_ROOT, filepath_short) # Construct full path
    if filepath_short in EXCLUDED_FILES or filepath_short.endswith(".g.dart"):
        continue # Skip excluded/generated files

    try:
        with open(filepath_full, "r", encoding="utf-8") as f:
            content_lines = f.readlines()
    except FileNotFoundError:
        # print(f"Warning: File not found: {filepath_full}", file=sys.stderr)
        continue
    except Exception as e:
        # print(f"Warning: Error reading file {filepath_full}: {e}", file=sys.stderr)
        continue

    current_patterns_for_file = PATTERNS
    if filepath_short.startswith("lib/preferences/"):
        current_patterns_for_file = PATTERNS + PREFERENCE_PATTERNS # Use combined set for preference files

    for line_num, line_content in enumerate(content_lines, 1):
        stripped_line = line_content.strip()
        # Skip comments
        if stripped_line.startswith("//") or stripped_line.startswith("/*") or stripped_line.endswith("*/") or stripped_line.startswith("*"):
            continue

        # Filter out logging/debug print statements more carefully
        # Regex to find common logging patterns: print(...), debugPrint(...), log.v(...), etc.
        log_print_pattern = r"\b(print|debugPrint|log\.(?:v|d|i|w|e|wtf|f|s))\s*\("
        if re.search(log_print_pattern, stripped_line):
            # Check if this log/print pattern is NOT part of a user-facing string literal itself
            is_genuinely_a_log_call = True
            for ui_pattern_check in current_patterns_for_file:
                for match_ui in ui_pattern_check.finditer(line_content):
                    for group_idx in range(1, ui_pattern_check.groups + 1):
                        ui_string_content = match_ui.group(group_idx)
                        if ui_string_content and re.search(log_print_pattern, ui_string_content):
                            # The logging pattern is *inside* a captured UI string.
                            # Example: Text("Please print this document.") - 'print' is part of the UI string.
                            is_genuinely_a_log_call = False
                            break
                    if not is_genuinely_a_log_call: break
                if not is_genuinely_a_log_call: break
            if is_genuinely_a_log_call:
                continue # Skip this line as it's a logging call, not UI text.

        if stripped_line.startswith("assert("): # Skip assert statements
            continue

        # Apply defined regex patterns to the current line
        for pattern in current_patterns_for_file:
            try:
                for match in pattern.finditer(line_content):
                    # Iterate through all capturing groups of the regex (e.g. for InputDecoration)
                    for i in range(1, pattern.groups + 1):
                        string_literal_match = match.group(i)
                        if string_literal_match: # If this group captured something
                            final_string = process_string_literal(string_literal_match, filepath_short, line_num)
                            if final_string: # If processing yields a valid user-facing string
                                results.append({"string": final_string, "file": filepath_short, "line": line_num})
            except re.error:
                # print(f"Regex error with pattern '{pattern.pattern}' on line: {line_content}", file=sys.stderr)
                pass # Ignore lines that cause regex errors for a specific pattern, try other patterns.

# Deduplication Phase 1: Remove entries that are identical in string, file, and line number.
# This handles cases where multiple regex patterns (e.g. a generic Text() and a more specific AlertDialog content)
# might match the exact same string on the same line.
unique_results_by_location = []
seen_locations_set = set()
for item in results:
    # Create a tuple that uniquely identifies an entry by its content and exact location
    location_tuple = (item["string"], item["file"], item["line"])
    if location_tuple not in seen_locations_set:
        unique_results_by_location.append(item)
        seen_locations_set.add(location_tuple)

# Deduplication Phase 2: Remove entries with identical strings, keeping the first encountered file/line.
# For localization, if the exact same string ("OK", "Cancel", etc.) is used in multiple places,
# it's typically translated once. We report the first place it was found.
final_unique_results_list = []
seen_strings_set = set()
for item in unique_results_by_location:
    normalized_string = item["string"].strip() # Ensure consistent stripping for uniqueness check
    if not normalized_string: # Skip if string somehow became empty after processing
        continue

    if normalized_string not in seen_strings_set:
        final_unique_results_list.append({"string": normalized_string, "file": item["file"], "line": item["line"]})
        seen_strings_set.add(normalized_string)

# Print the final JSON output
print(json.dumps(final_unique_results_list, indent=2))
```
