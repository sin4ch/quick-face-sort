# quick-face-sort
This project will sort through a folder and sort pictures & video into subfolders based on training with choice faces. This is great for sorting pictures and videos through very large folders without having to doing it manually.

# Back Story
---
I was trying to clear space on my phone. Notoriously, WhatsApp usually has a large portion of the filesystem due to unwanted videos, pictures, media in general, that we end up downloading and not exactly needing later. 

However, I realise that some of those pictures are important i.e they could have been pictures of family, friends etc that I really want to keep. So i can just delete the entire WhatsApp media folder. But, sometimes, these folders can be so large that it can be a chore to go through the entire folder and check for the media you want to keep.

I'm creating this as a way to automate this process. There are probably many tools that can do this. However, I want to build something like this from scratch.

# Plan
---
- a cloud based version, where I'll have to upload the directory to a cloud platform like S3 then the bucket is scanned using a service like rekognition
  - Maybe this will have a web-based UI where people can upload their pictures and it creates an isolated bucket (for security purposes) for them and starts a CI/CD pipeline
- a local version,
  - that probably can be installed in the command line (this'll be easier than a desktop frontend. Maybe you can work with Electron)
