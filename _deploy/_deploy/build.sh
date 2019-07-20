jekyll build --destination _deploy


cd _deploy
 
git add .
git commit -m "Static"

git push -u origin master 
cd ..

git add .
git commit -m "Source Added"
git push origin source
