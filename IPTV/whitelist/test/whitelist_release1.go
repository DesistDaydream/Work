package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"time"
)

type ipset struct {
	path string
	ips  []string
}

func (i *ipset) readIP() []string {
	file, openError := os.Open(i.path)
	if openError != nil {
		fmt.Printf("文件不存在或出现问题")
		os.Exit(1)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		i.ips = append(i.ips, scanner.Text())
	}
	return i.ips
}

func flushIpset() {
	flushIP := fmt.Sprintf("ipset flush")
	cmdFlushIP := exec.Command("/bin/bash", "-c", flushIP)
	if cmdFlushIP.Run() != nil {
		fmt.Println("清理ip失败")
		os.Exit(2)
	}
}

func (i *ipset) addIP() {
	for _, ip := range i.ips {
		addIP := fmt.Sprintf("ipset add lichenhao %s", ip)
		cmdAddIP := exec.Command("/bin/bash", "-c", addIP)
		if cmdAddIP.Run() != nil {
			fmt.Println("添加IP失败")
			os.Exit(2)
		}
	}
	i.ips = i.ips[:0]
	fmt.Println("确定ip列表是否已经清理。如果不清理，则会无限叠加", i.ips)
}

func main() {
	ipset := new(ipset)
	ipset.path = "./ip.txt"
	t, _ := strconv.Atoi(os.Args[1])
	c := time.Tick(time.Duration(t) * time.Second)
	for {
		<-c
		flushIpset()
		ipset.readIP()
		ipset.addIP()

	}
}
