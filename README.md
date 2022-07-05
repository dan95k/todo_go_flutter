# Todo go flutter
## A todo app that synchronizing the users todo's with a backend.

The project is using go (golang) with gin and sqlite3 for the backend part, and flutter dart for the frontend
the main reason for creating this project is to practice go language.

When opening the app, a welcome screen with email input appears.
when entering an email, the app querying the backend's database for that email.
when the server is receiving the request, it will  search the databse for a user with that email and will return
the users todo, or an empty array if new user, the todo lsit will be randered then on the app.

each action on the app is sent to the backend to be stored.
the available actions are:
1. creating new todo
2. deleting todo
3. checkng todo as finished
4. checking todo as unfinished

each todo has an urgency field, the available urgencies are: low, medium, high
and which urgency renders a different circle color to the left of the todo text.

for the databse, i have used sqlite, the data is stored inside two tables, one for users and one for todos
the tables are as follows:



<div align="center">

### Users:
|  | Id | Email | Todos |
| ----------- | ----------- | ----------- | ----------- |
| Type | Int | String | String |
| Example | 12 | "email@email.com" | "55 , 843 , 998 , 39" |
</div>



<div align="center">
  
### Todos:
|  | Id | Text | Finished | Urgency |
| ----------- | ----------- | ----------- | ----------- | ----------- |
| Type | Int | String | Int | Int |
| Example | 39 | "buy groceries" | 1 | 2 |
</div>

**To run, need to set the server address inside the .env file in the frontend folder**

<div align="center">
  
  ### GIF:
<p align="center">
  <img src="https://github.com/dan95k/todo_go_flutter/blob/main/images/app_demo.gif?raw=true" width="300" height="600" />
</p>

<!-- ![Alt Text](https://github.com/dan95k/todo_go_flutter/blob/main/images/app_demo.gif?raw=true) -->