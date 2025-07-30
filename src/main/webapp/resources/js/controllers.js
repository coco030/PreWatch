const isLoggedIn = document.getElementById("isLoggedIn")?.value === "true";
if (!isLoggedIn) {
    alert("로그인 후 이용 가능합니다.");
    return;
}