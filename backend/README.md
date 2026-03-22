# запуск 
backend$ python -m app.parsers.coffee_parser

# tests
python -m pytest -v

# Запуск среды
### Закройте все окна VS Code
killall code 2>/dev/null
### Откройте проект через workspace файл
code project.code-workspace