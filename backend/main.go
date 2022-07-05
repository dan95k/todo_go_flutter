package main

import (
	"database/sql"
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	_ "github.com/mattn/go-sqlite3"
)

var DB *sql.DB

func main() {
	connectToDb()
	createTables()

	router := gin.Default()

	router.POST("/login", loginUser)
	router.POST("/add_todo", addTodo)
	router.POST("/remove_todo", removeTodo)
	router.PUT("/check_todo", checkTodo)
	router.PUT("/uncheck_todo", uncheckTodo)

	//debug routes
	router.GET("/all_users", getAllUsers)
	router.GET("/all_todos", getAllTodos)

	router.Run(":3000")
}

func loginUser(c *gin.Context) {
	var req LoginReq
	c.BindJSON(&req)
	exists := isUserExist(req.Email)
	if exists {
		todos := getUserTodos(req.Email)
		c.JSON(200, todos)
	} else {
		statement, _ := DB.Prepare("INSERT INTO users (email,todos) VALUES (?,?)")
		statement.Exec(req.Email, "")
		c.JSON(201, map[string]string{"status": "ok"})
	}
}

func addTodo(c *gin.Context) {
	var req AddTodoReq
	c.BindJSON(&req)

	//insert todo to todos table
	statement, _ := DB.Prepare("INSERT INTO todos(text, finished, urgency) VALUES (?,?,?)")
	res, err := statement.Exec(req.Text, 0, req.Urgency)
	if err != nil {
		fmt.Println(err)
	}
	Id, _ := res.LastInsertId() //new todo id
	//get current user's todos from db
	statement, err = DB.Prepare("SELECT todos FROM users WHERE email=?")
	if err != nil {
		fmt.Println(err)
	}
	var todosString string
	err = statement.QueryRow(req.Email).Scan(&todosString)
	if err != nil {
		fmt.Println(err)
	}
	//add new todo id to list
	var todos []string
	if len(todosString) > 0 {
		todos = strings.Split(todosString, ",")
		todos = append(todos, strconv.Itoa(int(Id)))
	} else {
		todos = []string{strconv.Itoa(int(Id))}
	}
	//update todos in db
	statement, err = DB.Prepare("UPDATE users SET todos = ? WHERE email = ?")
	checkErr(err)
	_, err = statement.Exec(strings.Join(todos, ","), req.Email)
	checkErr(err)
	newTodo := Todo{Id: int(Id), Text: req.Text, Finished: 0, Urgency: req.Urgency} //construct new todo
	c.JSON(201, newTodo)
}

func removeTodo(c *gin.Context) {
	var req RemoveTodoReq
	c.BindJSON(&req)
	statement, err := DB.Prepare("SELECT todos FROM users WHERE email=?")
	checkErr(err)

	var todosString string
	err = statement.QueryRow(req.Email).Scan(&todosString)
	checkErr(err)

	oldTodos := strings.Split(todosString, ",")
	newTodos := []string{}
	for _, elem := range oldTodos {
		if elem != strconv.Itoa(req.Id) {
			newTodos = append(newTodos, elem)
		}
	}
	//update todos in user db
	statement, err = DB.Prepare("UPDATE users SET todos = ? WHERE email = ?")
	checkErr(err)
	_, err = statement.Exec(strings.Join(newTodos, ","), req.Email)
	checkErr(err)

	//update todos db
	statement, err = DB.Prepare("DELETE FROM todos WHERE id=?")
	checkErr(err)
	_, err = statement.Exec(req.Id)
	checkErr(err)
	c.JSON(200, map[string]string{"status": "ok"})
}

func checkTodo(c *gin.Context) {
	var req CheckTodoReq
	c.BindJSON(&req)
	statement, err := DB.Prepare("UPDATE todos SET finished = 1 WHERE id = ?")
	checkErr(err)
	_, err = statement.Exec(&req.Id)
	checkErr(err)
	c.JSON(http.StatusOK, map[string]string{"status": "ok"})
}

func uncheckTodo(c *gin.Context) {
	var req UncheckTodoReq
	c.BindJSON(&req)
	statement, err := DB.Prepare("UPDATE todos SET finished = 0 WHERE id = ?")
	checkErr(err)
	_, err = statement.Exec(&req.Id)
	checkErr(err)
	c.JSON(http.StatusOK, map[string]string{"status": "ok"})
}

func connectToDb() {
	db, err := sql.Open("sqlite3", "./todos.db")
	checkErr(err)
	DB = db

}

func createTables() {
	statement, err := DB.Prepare("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, email TEXT, todos TEXT)")
	checkErr(err)
	statement.Exec()
	statement, err = DB.Prepare("CREATE TABLE IF NOT EXISTS todos (id INTEGER PRIMARY KEY, text TEXT,finished INTEGER, urgency INT)")
	checkErr(err)
	statement.Exec()
}

func isUserExist(email string) bool {
	statement, err := DB.Prepare("select id FROM users WHERE email = ?")
	checkErr(err)
	var id int
	err = statement.QueryRow(email).Scan(&id)
	if err != nil {
		if err == sql.ErrNoRows {
			return false
		}
		fmt.Println(err)
	}
	return true
}

func getUserTodos(email string) []Todo {
	statement, err := DB.Prepare("SELECT todos FROM users WHERE email=?")
	checkErr(err)
	var Ids string
	statement.QueryRow(email).Scan(&Ids)
	query := fmt.Sprintf("SELECT * FROM todos WHERE id IN (%s)", Ids)
	rows, err := DB.Query(query)
	checkErr(err)
	var id int
	var text string
	var finished int
	var urgency int
	var todos []Todo
	for rows.Next() {
		rows.Scan(&id, &text, &finished, &urgency)
		t := Todo{Id: id, Text: text, Finished: finished, Urgency: urgency}
		todos = append(todos, t)
	}
	return todos
}

func getAllUsers(c *gin.Context) {
	rows, _ := DB.Query("SELECT id,email,todos from users")
	var id int
	var email string
	var todos string
	var users []User
	for rows.Next() {
		rows.Scan(&id, &email, &todos)
		u := User{Id: id, Email: email, Todos: todos}
		users = append(users, u)
	}
	c.JSON(200, users)
}
func getAllTodos(c *gin.Context) {
	rows, _ := DB.Query("SELECT * from todos")
	var id int
	var text string
	var finished int
	var urgency int
	var todos []Todo
	for rows.Next() {
		rows.Scan(&id, &text, &finished, &urgency)
		t := Todo{Id: id, Text: text, Finished: finished, Urgency: urgency}
		todos = append(todos, t)
	}
	c.JSON(200, todos)
}

func checkErr(err error) {
	if err != nil {
		panic(err)
	}
}
