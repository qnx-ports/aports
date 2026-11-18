#!/usr/bin/python3
"""Convert the results of ntpsec's `waf check` to JUnit XML.

usage: waf-junit.py <build/main/test.log> <waf check output> <out.xml>

test.log has one block per test program (BINARY / RETURN VALUE / stdout / stderr).
Unity programs print one "TEST(group, name) PASS|IGNORE|<file>:<line>::FAIL: ..." line
per case and become one testcase each; other programs (the pylib unittest suites,
libaes_siv) become a single testcase judged by their return value. The
"running: <binary> --version OK|SKIPPING" lines of the waf output become the
"binary-checks" suite.
"""
import os
import re
import sys
import xml.etree.ElementTree as ET

ANSI = re.compile(r"\x1b\[[0-9;]*m")
UNITY = re.compile(r"^TEST\((\w+), (\w+)\)(.*)$")
RUNNING = re.compile(r"^running: (\S+)(?: (.*?))?\s+(OK|SKIPPING.*|FAIL.*)\s*$")


def read(path):
    with open(path, encoding="utf-8", errors="replace") as f:
        return ANSI.sub("", f.read())


def blocks(log):
    """Yield (binary, return value, stdout, stderr) for each program."""
    for chunk in re.split(r"^(?=BINARY\s*:)", log, flags=re.M):
        m = re.match(r"BINARY\s*:\s*(.*)\nRETURN VALUE:\s*(-?\d+)", chunk)
        if not m:
            continue
        out = re.search(r"\*\*\* stdout \*\*\*\n(.*?)(?=^\*\*\* stderr \*\*\*|\Z)", chunk, re.S | re.M)
        err = re.search(r"\*\*\* stderr \*\*\*\n(.*)", chunk, re.S)
        yield (m.group(1).strip(), int(m.group(2)),
               out.group(1) if out else "", err.group(1) if err else "")


def suite(root, name):
    return ET.SubElement(root, "testsuite", name=name)


def case(s, classname, name, failure=None, skipped=None, output=None):
    c = ET.SubElement(s, "testcase", classname=classname, name=name)
    if failure is not None:
        ET.SubElement(c, "failure", message=failure.splitlines()[0][:200] if failure else "failed").text = failure
    elif skipped is not None:
        ET.SubElement(c, "skipped", message=skipped)
    if output:
        ET.SubElement(c, "system-out").text = output


def unity_cases(s, prog, stdout):
    current = None  # [group, name, rest-of-line + continuation lines]
    found = False

    def flush():
        if current is None:
            return
        group, name, text = current
        text = text.strip()
        lines = [l for l in text.splitlines() if l.strip()]
        fails = [l for l in lines if ":FAIL" in l]
        if fails:
            case(s, prog + "." + group, name, failure="\n".join(fails), output=text)
        elif lines and lines[-1].strip().endswith("IGNORE"):
            case(s, prog + "." + group, name, skipped=lines[-1].strip(), output=text)
        elif lines and lines[-1].strip().endswith("PASS"):
            case(s, prog + "." + group, name, output=text if len(lines) > 1 or text != "PASS" else None)
        else:
            case(s, prog + "." + group, name, failure="no result printed\n" + text)

    for line in stdout.splitlines():
        m = UNITY.match(line)
        if m:
            flush()
            current = [m.group(1), m.group(2), m.group(3)]
            found = True
        elif current is not None and not re.match(r"^(-{5,}|\d+ Tests \d+ Failures)", line):
            current[2] += "\n" + line
        else:
            flush()
            current = None
    flush()
    return found


def main(test_log, waf_out, out_xml):
    root = ET.Element("testsuites", name="ntpsec waf check")
    if not os.path.exists(test_log):
        case(suite(root, "waf-check"), "waf-check", "test.log",
             failure="%s was not written; waf stopped before running the tests" % test_log)
        test_log = os.devnull
    for binary, rc, stdout, stderr in blocks(read(test_log)):
        prog = os.path.basename(binary)
        s = suite(root, prog)
        if not unity_cases(s, prog, stdout) or rc != 0 and s.find("testcase/failure") is None:
            # not a Unity program, or it failed without a failing case (crash, abort)
            case(s, prog, prog,
                 failure=None if rc == 0 else "return value %d\n%s" % (rc, stderr),
                 output=stdout + stderr)
    s = suite(root, "binary-checks")
    seen = set()  # waf prints its log of binary checks more than once
    for line in read(waf_out).splitlines():
        m = RUNNING.match(line)
        if m:
            name = os.path.basename(m.group(1)) + (" " + m.group(2) if m.group(2) else "")
            if name in seen:
                continue
            seen.add(name)
            if m.group(3) == "OK":
                case(s, "binary-checks", name)
            elif m.group(3).startswith("SKIPPING"):
                case(s, "binary-checks", name, skipped=m.group(3))
            else:
                case(s, "binary-checks", name, failure=m.group(3))
    totals = [0, 0, 0]
    for s in root:
        counts = [len(s.findall("testcase")), len(s.findall("testcase/failure")),
                  len(s.findall("testcase/skipped"))]
        s.set("tests", str(counts[0]))
        s.set("failures", str(counts[1]))
        s.set("skipped", str(counts[2]))
        s.set("errors", "0")
        totals = [a + b for a, b in zip(totals, counts)]
    root.set("tests", str(totals[0]))
    root.set("failures", str(totals[1]))
    root.set("skipped", str(totals[2]))
    root.set("errors", "0")
    ET.ElementTree(root).write(out_xml, encoding="utf-8", xml_declaration=True)
    print("junit: %d tests, %d failures, %d skipped -> %s" % (totals[0], totals[1], totals[2], out_xml))


if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    main(*sys.argv[1:])
