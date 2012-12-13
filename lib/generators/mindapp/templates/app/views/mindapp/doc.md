<style>code { font-size: 0.8em;}</style>

<%= File.read('README.md') %>

***

# คู่มือการใช้งาน

<%= render :partial=>'mindapp/modul.md', :collection=> Mindapp::Module.all.asc(:seq) %>

***

# คู่มือผู้ดูแลระบบ

## โครงสร้างข้อมูล

<%- models= @app.elements["//node[@TEXT='models']"] %>

<%= render :partial=>'mindapp/model.md', :collection=> models.map {|m| m.attributes["TEXT"] } %>

***

# ภาคผนวก

## markdown

คู่มือนี้จัดทำขึ้นโดยอัตโนมัติจาก mind map และส่วนต่างๆ ของรหัสโปรแกรม 
ผู้เกี่ยวข้องสามารถเขียนวิธีการใช้งานได้อย่างอิสระ โดยใช้คำสั่ง
<a href="http://daringfireball.net/projects/markdown/syntax" target="_blank">markdown</a>
ในการเขียนคู่มือประกอบเข้ากับส่วนต่างๆของระบบงาน ดังต่อไปนี้

* คำอธิบายระบบในภาพรวม อยู่ในไฟล์ `README.md`
* คำอธิบายระบบงาน อยู่ในไฟล์ `app/controllers/<ระบบงาน>.md`
* คำอธิบายงาน อยู่ในไฟล์ `app/views/<ระบบงาน>/<งาน>.md`
* คำอธิบายงานของ link สร้างเป็นกิ่งลูกต่อจาก link นั้น
* คำอธิบายขั้นตอน อยู่ในไฟล์ `app/views/<ระบบงาน>/<งาน>/<ขั้นตอน>.md`
* ตัวอย่างหน้าจอ อยู่ในไฟล์ `app/views/<ระบบงาน>/<งาน>/<ขั้นตอน>.png`
