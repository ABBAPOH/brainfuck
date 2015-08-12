import qbs
import qbs.FileInfo
import qbs.TextFile

Product {
    type: "brainfuck_out"
    name: "BrainFuck"
    files: [ "helloworld.brainfuck" ]

    FileTagger {
        patterns: "*.brainfuck"
        fileTags: ["brainfuck"]
    }

    Rule {
        id: brainfuck
        inputs: ["brainfuck"]
        Artifact {
            filePath: input.fileName + '.out'
            fileTags: "brainfuck_out"
        }
        prepare: {
            var cmd = new JavaScriptCommand();
            cmd.description = "Processing '" + input.fileName + "'";
            cmd.highlight = "codegen";
            cmd.sourceCode = function() {
                var file = new TextFile(input.filePath);
                var acc = file.readAll();
                file.close()
                var cpu = [0];
                var j = 0;
                var brc = 0;
                var result = "";
                for (var i = 0; i < acc.length; i++) {
                    if(acc[i] == '>') j++;
                    if(acc[i] == '<') j--;
                    if(acc[i] == '+') cpu[j]++;
                    if(acc[i] == '-') cpu[j]--;
                    if(acc[i] == '.') result += String.fromCharCode(cpu[j]);
                    if(acc[i] == ',') result += String.fromCharCode(cpu[j]);
                    if(acc[i] == '[')
                    {
                        if(!cpu[j])
                        {
                            ++brc;
                            while(brc)
                            {
                                ++i;
                                if (acc[i] == '[') ++brc;
                                if (acc[i] == ']') --brc;
                            }
                        }else continue;
                    }
                    else if(acc[i] == ']')
                    {
                        if(!cpu[j])
                        {
                            continue;
                        }
                        else
                        {
                            if(acc[i] == ']') brc++;
                            while(brc)
                            {
                                --i;
                                if(acc[i] == '[') brc--;
                                if(acc[i] == ']') brc++;
                            }
                            --i;
                        }
                    }
                }
                file = new TextFile(output.filePath, TextFile.WriteOnly);
                file.truncate();
                file.write(result);
                file.close();
            }
            return cmd;
        }
    }
}
