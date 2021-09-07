import { readFileSync, writeFileSync } from 'fs';




const configReducer = (fileName) => {
    const dataArr = readFileSync(fileName, 'utf8').split('\n');
    const filteredData = dataArr.filter((line) => {
        if (line.startsWith('#')) return false;
        if (line.length === 0) return false;
        return true;
    }).sort();
    writeFileSync(`${fileName}slim`,  filteredData.join('\n'), 'utf8');
}

configReducer('new.config');
configReducer('ax6min.config');