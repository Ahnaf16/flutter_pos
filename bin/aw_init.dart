void main(List<String> args) {
  // create project

  // create db
  // appwrite databases create --database-id 6805362c0032bd189cd2 --name pos_db

  //create admin
  // appwrite users create --user-id "unique()" \
  //     --email admin@gmail.com \
  //     --password 12341234

  //create config doc
  // appwrite databases create-document \
  //     --database-id "6805362c0032bd189cd2" --collection-id "6805c476002d4333ccb1" \
  //     --document-id 'APP_CONFIG' --data '$_defConfig' \
  //     --permissions 'read("any")' 'write("users")' 'update("users")'
}

// final _defConfig = json.encode(Config.def().toAwPost());

//  aw databases create-string-attribute --database-id 6805362c0032bd189cd2 --collection-id 6805c476002d4333ccb1 --key currency_symbol --size 15 --required false --xdefault "$"


   // create-boolean-attribute 
  
   // create-datetime-attribute 
   
   // create-email-attribute 
  
   // create-enum-attribute 
   
   // create-float-attribute 
   
   // create-integer-attribute 
   
   // create-ip-attribute 
  
   // create-relationship-attribute 

   // create-string-attribute 
  
                                           