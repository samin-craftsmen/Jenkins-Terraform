package main

import (
    "github.com/aws/aws-lambda-go/lambda"
)

func handler() string {
    return "Hello from Lambda"
}

func main() {
    lambda.Start(handler)
}