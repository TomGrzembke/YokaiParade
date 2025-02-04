powershell -Command "Compress-Archive -Force -LiteralPath yokaiparade-html/ -DestinationPath yokaiparade-html.zip"

butler push ./yokaiparade-html.zip pretentious-possums/YokaiParade:html