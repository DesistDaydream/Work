package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"time"

	ipset "github.com/gmccue/go-ipset"
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
	// fmt.Println(w.ips)
	return w.ips
}

func (w *whiteList) testIP() {
	ipset, _ := ipset.New()
	for _, ip := range w.ips {
		testError := ipset.Test("lichenhao", ip)
		if testError != nil {
			fmt.Printf("在 %s 添加 %s \n", time.Now().Format("2006/1/2 15:04:05"), ip)
			w.addIP()
		}
	}
	// 确定ip列表是否已经清理。如果不清理，则会无限叠加
	w.ips = w.ips[:0]
}

func (w *whiteList) addIP() {
	ipset, _ := ipset.New()
	// createError := ipset.Create("lichenhao", "hash:net")
	// if createError != nil {
	// 	fmt.Printf("创建集合失败,因为：%s\n", createError)
	// }
	flushError := ipset.Flush("lichenhao")
	if flushError != nil {
		fmt.Printf("清理条目失败,因为：%s\n", flushError)
	}
	for _, ip := range w.ips {
		addError := ipset.Add("lichenhao", ip)
		if addError != nil {
			fmt.Printf("添加条目%s失败,因为：%s\n", ip, addError)
		}
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
