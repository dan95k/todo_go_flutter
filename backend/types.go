package main

type User struct {
	Id    int
	Email string
	Todos string
}

type Todo struct {
	Id       int
	Text     string
	Finished int
	Urgency  int
}

type LoginReq struct {
	Email string
}
type AddTodoReq struct {
	Email   string
	Text    string
	Urgency int
}
type RemoveTodoReq struct {
	Email string
	Id    int
}
type CheckTodoReq struct {
	Id int
}
type UncheckTodoReq struct {
	Id int
}
