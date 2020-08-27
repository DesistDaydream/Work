/*
Copyright © 2019 NAME HERE <EMAIL ADDRESS>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package cmd

import (
	"fmt"
	"os"
	"regexp"
	"whitelist/update"

	"github.com/spf13/cobra"
)

// updateCmd represents the update command
var updateCmd = &cobra.Command{
	Use:   "update",
	Short: "更新指定cdn源站类型",
	Long: `更新指定的cdn源站类型的ip白名单,可用的源站类型有以下几种：
baishan
huawei
qiniu
wangsu`,
	Run: func(cmd *cobra.Command, args []string) {
		if matchResult, _ := regexp.MatchString("(\\bali\\b|\\bbaishan\\b|\\bhuawei\\b|\\bqiniu\\b|\\bwangsu\\b)", update.IpsetName); matchResult == false {
			// if update.IpsetName != "baishan" && update.IpsetName != "huawei" && update.IpsetName != "qiniu" && update.IpsetName != "wangsu" {
			fmt.Println("请使用 --cdn 指定正确的CDN源站类型，比如huawei、baishan等")
			os.Exit(1)
		}

		if updateError := update.Update(update.IpsetName, update.Time); updateError != nil {
			fmt.Printf("更新失败，因为 %s", updateError)
			os.Exit(1)
		}
		// fmt.Println("更新成功")
	},
}

func init() {
	rootCmd.AddCommand(updateCmd)
	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// updateCmd.PersistentFlags().StringVar(&update.F, "path", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	updateCmd.Flags().StringVar(&update.IpsetName, "cdn", "", "指定cdn源站类型，e.g.huawei、wangsu")
	updateCmd.Flags().Int64Var(&update.Time, "time", 0, "指定程序运行时间间隔，如果不指定，则默认执行一次更新")
}
