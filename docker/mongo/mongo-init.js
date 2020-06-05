db.auth('root', 'root_password')
db = db.getSiblingDB('sweagle')
db.createUser({
  user: "staticTreeUser",
  pwd: "password",
  roles: [
    {
      role: "readWrite",
      db: "sweagle"
    }
  ]
});
