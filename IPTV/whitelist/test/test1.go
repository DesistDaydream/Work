package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"time"

	"github.com/gmccue/go-ipset"
)

type whiteList struct {
	path string
	ips  []string
}

func (w *whiteList) readIP() []string {
	file, openError := os.Open(w.path)
	if openError != nil {
		fmt.Printf("文件不存在或出现问题")
		os.Exit(1)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		w.ips = append(w.ips, scanner.Text())
	}
	return w.ips
}

func (w *whiteList) testIP() {
	ipset, _ := ipset.New()
	for _, ip := range w.ips {
		testError := ipset.Test("lichenhao", ip)
		fmt.Println(testError)
	}
}

func main() {
	whiteList := new(whiteList)
	whiteList.path = "./ip.txt"

	// 使用命令行参数指定程序运行时间间隔
	t, _ := strconv.Atoi(os.Args[1])
	c := time.Tick(time.Duration(t) * time.Second)
	for {
		<-c
		whiteList.readIP()
		whiteList.testIP()
		// whiteList.addIP()

	}
}
