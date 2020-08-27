package main

import (
	"fmt"
	"os"
	"regexp"
)

func main() {
	bool, _ := regexp.MatchString(os.Args[1], "^(baishan|qiniu|wangsu)(?:live|vod)$")
	fmt.Println(bool)
}
