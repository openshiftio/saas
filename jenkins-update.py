
from saasherder.saasherder import SaasHerder
import requests
import json



service_dirs = ["dsaas-services", "launchpad-services"]

def update(service_dir, output_dir):
  builds = []
  print("Directory: " +service_dir)
  se = SaasHerder(service_dir, output_dir)

  services = se.get_services("all")
  for s in services:
    url = s["url"].rstrip("/")
    repo_list = url.split("/")
    build_name = "devtools-%s-build-master" % (repo_list[-1])
    if "launchpad" in repo_list[-1]:
      build_name = "devtools-%s-generator-build-master" % (repo_list[-1]) 
    elif "fabric8-ui" in repo_list[-1]:
      build_name = "devtools-%s-npm-publish-build-master" % (repo_list[-1])
    elif "saas" in repo_list[-1]:
      continue
    builds.append((s["name"], build_name))


  for n, b in builds:
    print("Build: %s" % b)
    uri = "https://ci.centos.org/job/%s/api/json" % b
    r = requests.get(uri)
    p = b
    try:
      js = json.loads(r.content)
      r2 = requests.get("%s/api/json" % js["lastSuccessfulBuild"]["url"])
      js2 = json.loads(r2.content)
      
      p += " %s" % (js2["result"])
      if js2["result"] == "SUCCESS":
        for a in js2["actions"]:
          if "lastBuiltRevision" in a:
            h = a["lastBuiltRevision"]["SHA1"]
        print("Found hash: %s" % h)
        se.update("hash", n, h)
    except ValueError as e:
      pass
    finally:
      print

for d in service_dirs:
  update(d, "%s-templates" % d.split("-")[-1])