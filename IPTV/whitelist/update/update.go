package update

import (
	"bufio"
	"fmt"
	"net"
	"os"
	"time"

	ipset "github.com/gmccue/go-ipset"
)

type whiteList struct {
	File string
	Ips  []string
}

func (w *whiteList) ReadIP() ([]string, error) {
	file, openError := os.Open(w.File)
	if openError != nil {
		return nil, fmt.Errorf("获取IP列表失败，原因：%w", openError)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		ip := scanner.Text()
		_, ipnet, _ := net.ParseCIDR(ip)
		if ipnet != nil || net.ParseIP(ip) != nil {
			w.Ips = append(w.Ips, ip)
		}
	}
	return w.Ips, nil
}

func (w *whiteList) TestIP(IpsetName string) error {
	ipset, _ := ipset.New()
	// fmt.Println("测试前的IP数量", w.Ips)
	// fmt.Println("当前ipset名字", IpsetName)
	// 逐行判断列表中的ip是否存在在ipset中
	for _, ip := range w.Ips {
		if testInfo := ipset.Test(IpsetName, ip); testInfo != nil {
			return testInfo
		}
	}
	// fmt.Println("测试完成，无需修改IP")
	return nil
}

func (w *whiteList) AddIP(IpsetName string) error {
	ipset, _ := ipset.New()
	// 给指定ipset逐条添加条目
	for _, ip := range w.Ips {
		if addError := ipset.AddUnique(IpsetName, ip); addError != nil {
			return fmt.Errorf("添加条目失败，原因：%w", addError)
		}
	}
	fmt.Printf("time=\"%s\" 成功更新 %s 的IP \n", time.Now().Format("2006/1/2 15:04:05"), IpsetName)
	// fileName := "/var/log/whitelist.log"
	// logFile, err := os.Create(fileName)
	// defer logFile.Close()
	// if err != nil {
	// 	log.Fatalln("ope file error")
	// }
	// debugLog := log.New(logFile, "[Info]", log.LstdFlags)
	// debugLog.Printf("在 %s 修改了 %s 的IP \n", time.Now().Format("2006/1/2 15:04:05"), IpsetName)

	return nil
}

func (w *whiteList) FlushIP(IpsetName string) error {
	ipset, _ := ipset.New()
	// 清理指定ipset下的全部条目
	// fmt.Printf("清理条目 %s 完成\n", IpsetName)
	return ipset.Flush(IpsetName)
}

// CreateIPSet 创建指定的ipset集合
func CreateIPSet(a string, b string) {
	ipset, _ := ipset.New()
	ipset.Create(a, "hash:net", "-exist")
	if a != b {
		ipset.Create(b, "hash:net", "-exist")
	}
}
