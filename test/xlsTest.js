const fs = require('fs')
const xlsx = require('node-xlsx');
let date = require("silly-datetime");
var temp = [];
temp.push([1]);
temp.push([1]);
temp.push([1]);
temp.push([1]);
let xlsxObj = [
    {
        name: 'firstSheet',
        data: 
			temp
        ,
    },
    {
        name: 'secondSheet',
        data: [
            [7, 8, 9],
            [10, 1, 12]
        ],
    }
]
console.log(temp);
fs.writeFileSync(('./doc/'+date.format(new Date(), 'MMDD_HH_mm_ss')+'.xlsx'),xlsx.build(xlsxObj),"binary");