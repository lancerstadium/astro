@echo off

set project_path=D:\code\mad-motion
set commit_message=Auto commit at %date% %time%

cd %project_path%

git add .
git commit -m "%commit_message%"
git push

echo Blog committed at %date% %time% Successfully!
