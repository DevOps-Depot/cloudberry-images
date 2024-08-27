import testinfra
import re

def test_xerces_c_installed(host):
    # Verify that Xerces-C library exists
    xerces_lib = host.file("/usr/local/xerces-c/lib/libxerces-c-3.2.so")
    assert xerces_lib.exists, "Xerces-C library does not exist"
    assert xerces_lib.is_file, "Xerces-C library is not a file"

def test_xerces_c_headers(host):
    # Verify that Xerces-C headers are installed
    xerces_header = host.file("/usr/local/xerces-c/include/xercesc/util/XercesVersion.hpp")
    assert xerces_header.exists, "Xerces-C header file does not exist"
    assert xerces_header.is_file, "Xerces-C header is not a file"

def test_xerces_c_version(host):
    # Check Xerces-C version by grepping for individual version components
    version_cmd = host.run("cat /usr/local/xerces-c/include/xercesc/util/XercesVersion.hpp")

    assert version_cmd.succeeded, "Failed to retrieve Xerces-C version information"

    # Print full output for debugging
    print(f"XercesVersion.hpp content:\n{version_cmd.stdout}")

    # Extract version numbers using regex
    # Look for the last occurrence of each version component
    major = re.findall(r'#define\s+XERCES_VERSION_MAJOR\s+(\d+)', version_cmd.stdout)[-1]
    minor = re.findall(r'#define\s+XERCES_VERSION_MINOR\s+(\d+)', version_cmd.stdout)[-1]
    revision = re.findall(r'#define\s+XERCES_VERSION_REVISION\s+(\d+)', version_cmd.stdout)[-1]

    version = f"{major}.{minor}.{revision}"
    print(f"Extracted version: {version}")

    assert version == "3.2.5", f"Unexpected Xerces-C version: {version}"

def test_xerces_c_pkg_config(host):
    # Verify that pkg-config is properly set up for Xerces-C
    cmd = host.run("pkg-config --modversion xerces-c")
    assert cmd.succeeded, f"pkg-config for Xerces-C failed: {cmd.stderr}"
    print(f"pkg-config version: {cmd.stdout.strip()}")
    assert cmd.stdout.strip() == "3.2.5", f"Unexpected Xerces-C version from pkg-config: {cmd.stdout.strip()}"

def test_xerces_c_linkage(host):
    # Create a minimal C++ program that uses Xerces-C
    test_program = """
    #include <xercesc/util/PlatformUtils.hpp>
    #include <iostream>

    int main() {
        try {
            xercesc::XMLPlatformUtils::Initialize();
            std::cout << "Xerces-C initialized successfully!" << std::endl;
            xercesc::XMLPlatformUtils::Terminate();
        }
        catch (const xercesc::XMLException& e) {
            std::cerr << "Xerces-C initialization failed" << std::endl;
            return 1;
        }
        return 0;
    }
    """

    # Write the test program to a file
    host.check_output("cat << EOF > /tmp/xerces_test.cpp\n%s\nEOF" % test_program)

    # Compile the test program
    compile_cmd = host.run("g++ -I/usr/local/xerces-c/include -L/usr/local/xerces-c/lib -o /tmp/xerces_test /tmp/xerces_test.cpp -lxerces-c")
    assert compile_cmd.succeeded, f"Failed to compile Xerces-C test program: {compile_cmd.stderr}"

    # Run the compiled program with LD_LIBRARY_PATH set
    run_cmd = host.run("LD_LIBRARY_PATH=/usr/local/xerces-c/lib /tmp/xerces_test")
    assert run_cmd.succeeded, f"Failed to run Xerces-C test program: {run_cmd.stderr}"
    assert "Xerces-C initialized successfully!" in run_cmd.stdout, "Xerces-C initialization message not found in output"

def test_xerces_c_executable(host):
    # Verify that a Xerces-C executable (like SAX2Count) exists and is executable
    xerces_exec = host.file("/usr/local/xerces-c/bin/SAX2Count")
    assert xerces_exec.exists, "Xerces-C executable does not exist"
    assert xerces_exec.is_file, "Xerces-C executable is not a file"
    assert xerces_exec.mode == 0o755, "Incorrect permissions on Xerces-C executable"

    # Create a simple XML file for testing
    host.check_output("echo '<root><element>Test</element></root>' > /tmp/test.xml")

    # Try to run the executable with a simple XML file
    run_cmd = host.run("LD_LIBRARY_PATH=/usr/local/xerces-c/lib /usr/local/xerces-c/bin/SAX2Count /tmp/test.xml")
    assert run_cmd.succeeded, f"Failed to run Xerces-C executable: {run_cmd.stderr}"
    assert "2" in run_cmd.stdout, "SAX2Count did not produce expected output (element count)"
