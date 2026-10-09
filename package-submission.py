"""Package Ravi's actual console screenshots and project code; exclude credentials."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
root=Path(__file__).parent
output=root/'iPhone-Sales-Submission.zip'
names=['pipeline.py','env.sh','README.md','PROJECT_REPORT.md','VALIDATION.md','PROJECT_INFO.txt','start-services.sh','run-project.ps1','capture-native.ps1','run-console-evidence.ps1','prepare-actual-evidence.py','validate-actual.py','make-screenshot-index.py']
files=[root/name for name in names]
files+=list((root/'submission-documents').glob('*.docx'))
files+=list((root/'data').glob('*.csv'))
files+=[root/'sql'/'evidence.sql',root/'sql'/'project-metadata.sql']
files+=list((root/'sql'/'actual').glob('*.sql'))
files+=[root/'screenshots'/f'{n}.png' for n in range(1,13)]
files+=[root/'screenshots'/'index.html']
files+=[root/'logs'/f'actual-evidence-{n:02d}.log' for n in range(1,13)]
files+=[root/'logs'/'project-metadata.log']
assert all(p.exists() for p in files),'A final project file is missing'
with ZipFile(output,'w',ZIP_DEFLATED) as archive:
    for file in sorted(files): archive.write(file,file.relative_to(root).as_posix())
with ZipFile(output) as archive:
    assert 'credentials.txt' not in archive.namelist()
    assert archive.testzip() is None
print(output)

