import sys

# List of dependencies to test
dependencies = [
    ("scikit-learn", "sklearn"),
    ("pandas", "pandas"),
    ("numpy", "numpy"),
    ("psycopg2", "psycopg2"),
    ("sqlalchemy", "sqlalchemy"),
    ("statsmodels", "statsmodels"),
    ("matplotlib", "matplotlib"),
    ("seaborn", "seaborn"),
    ("networkx", "networkx"),
    ("scipy", "scipy"),
    ("pylca", "pylca")
]

# Test the import of each package
for package_name, import_name in dependencies:
    try:
        __import__(import_name)
        print(f"Successfully imported {package_name}")
    except ImportError as e:
        print(f"Failed to import {package_name}: {str(e)}")
        sys.exit(1)  # Exit if any package fails to import

print("All dependencies are installed and working correctly!")
