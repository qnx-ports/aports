import sys
import glob
import os
import xml.etree.ElementTree as ET

testdir, outfile = sys.argv[1], sys.argv[2]
suite = ET.Element("testsuite", name="vim")
passed = failed = 0

for f in sorted(glob.glob(os.path.join(testdir, "test_*.vim"))):
    name = os.path.basename(f).removesuffix(".vim")
    tc = ET.SubElement(suite, "testcase", name=name, classname="vim")
    if not os.path.exists(os.path.join(testdir, name + ".res")):
        ET.SubElement(tc, "failure", message="no .res file — test did not complete")
        failed += 1
    else:
        passed += 1

suite.set("tests", str(passed + failed))
suite.set("failures", str(failed))
tree = ET.ElementTree(suite)
ET.indent(tree, space="  ")
tree.write(outfile, encoding="unicode", xml_declaration=True)
