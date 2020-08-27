package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"os"
	"os/exec"
	"strings"
)

var (
	ipFile string
	changeFile string
)

func init() {
	flag.StringVar(&ipFile, "i", " ", "指定要使用的ip列表文件")
	flag.StringVar(&changeFile, "f", " ", "指定要修改ip的配置文件的列表")
	
}
func main() {
	flag.Parse()
	switch os.Args[1] {
	case "-i":
		ReadChangeFile()
	case "-f":
		ReadChangeFile()
	}

}

func ReadChangeFile() {
	inputFile, inputError := os.Open(changeFile)
	if inputError != nil {
		fmt.Printf("没有这个changeFile,请使用-f选项指定正确的目录列表文件")
		os.Exit(1)
	}
	defer inputFile.Close()

	inputReader := bufio.NewReader(inputFile)
	for inputByte, _, readerError := inputReader.ReadLine();readerError != io.EOF;inputByte, _, readerError = inputReader.ReadLine() {				
		inputString := string(inputByte)		
		if _, err := os.Stat(inputString); err != nil {
			fmt.Println("无该配置文件文件，继续修改下一个")
			continue
		}
		ReadIPFile(inputString)		
	}			
}
func ReadIPFile(FilePath string) {
	ipSlice := make([]string, 0, 2)
	inputFile, inputError := os.Open(ipFile)
	if inputError != nil {
		fmt.Printf("没有这个ipFile，请使用-i指定正确的要修改的IP列表文件")
		os.Exit(1)
	}
	defer inputFile.Close()
	inputReader := bufio.NewReader(inputFile)

	for {
		inputByte, _, readerError := inputReader.ReadLine()
		if readerError == io.EOF {
			break
		}
		inputString := string(inputByte)
		ipSlice = strings.Split(inputString, " ")
		// fmt.Println(ipSlice)
		ChangeIP(ipSlice,FilePath)
	}
}

func ChangeIP(ip []string, FilePath string) {
		param := fmt.Sprintf("sudo sed -i 's/%s/%s/g' %s > /dev/null", ip[0], ip[1], FilePath)
		cmd := exec.Command("/bin/bash", "-c", param)
		// cmd.Run()	//当命令有误时，可以进行调试，这个不会进行判断错误信息，继续执行后面的语句
		fmt.Println(param)
		if _, err := cmd.Output(); err != nil {
		fmt.Println(err)
			os.Exit(1) 
		}
		
}
