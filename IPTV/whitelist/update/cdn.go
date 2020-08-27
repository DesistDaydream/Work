package update

import (
	"time"
)

// Update 执行更新
func Update(i string, t int64) error {
	w := new(whiteList)
	w.File = "/usr/local/openresty/nginx/" + i + ".txt"
	IpsetNum := 1
	IpsetNameA := i + "1"
	IpsetNameB := i + "2"

	if t != 0 {
		CreateIPSet(IpsetNameA, IpsetNameB)
		c := time.Tick(time.Duration(t) * time.Second)
		for {
			<-c
			if _, readErr := w.ReadIP(); readErr != nil {
				return readErr
			}
			if IpsetNum == 1 {
				CreateIPSet(IpsetNameA, IpsetNameB)
				if w.TestIP(IpsetNameA) != nil {
					if updateIPError := w.AddIP(IpsetNameB); updateIPError != nil {
						return updateIPError
					}
					if flushIPError := w.FlushIP(IpsetNameA); flushIPError != nil {
						return flushIPError
					}
					IpsetNum = 2
				}
			} else {
				CreateIPSet(IpsetNameA, IpsetNameB)
				if w.TestIP(IpsetNameB) != nil {
					if updateIPError := w.AddIP(IpsetNameA); updateIPError != nil {
						return updateIPError
					}
					if flushIPError := w.FlushIP(IpsetNameB); flushIPError != nil {
						return flushIPError
					}
					IpsetNum = 1
				}
			}
			// 确定ip列表是否已经清理。如果不清理，则会无限叠加数组中ip的个数
			w.Ips = w.Ips[:0]
		}
	}

	if _, readErr := w.ReadIP(); readErr != nil {
		return readErr
	}
	if w.TestIP(i) != nil {
		CreateIPSet(i, i)
		w.FlushIP(i)
		w.AddIP(i)
	}
	return nil
}
