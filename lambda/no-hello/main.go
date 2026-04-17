package main

import (
	"github.com/aws/aws-lambda-go/lambda"
)

func handler() string {
	return "No Hello from Lambda"
}

func main() {
	lambda.Start(handler)
}
