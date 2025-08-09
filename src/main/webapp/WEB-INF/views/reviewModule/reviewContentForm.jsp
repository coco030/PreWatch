<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
    #reviewContentBox.truncated {
        max-height: 85px;
        overflow: hidden;
        -webkit-mask-image: linear-gradient(to bottom, black 60%, transparent 100%);
        mask-image: linear-gradient(to bottom, black 60%, transparent 100%);
    }
</style>

<!-- 영화 ID & 멤버 ID -->
<input type="hidden" id="movieId" value="${movieId}" />
<c:if test="${not empty loginMember}"><input type="hidden" id="memberId" value="${loginMember.id}" /></c:if>

<%-- 1. 로그인한 경우 --%>
<c:if test="${not empty loginMember}">
    <div id="reviewWriteBox" class="mb-3" style="max-width: 600px; width: 100%; <c:if test='${not empty myReview.reviewContent}'>display: none;</c:if>">
        <textarea id="reviewContentInput" class="form-control border-0 border-bottom rounded-0 px-1 py-2" rows="1" placeholder="리뷰를 남겨보세요." style="width: 100%; resize: vertical; overflow-y: hidden; background-color: transparent;">${fn:escapeXml(myReview.reviewContent)}</textarea>
        <div class="text-end mt-2">
            <button class="btn btn-dark btn-sm" id="saveReviewContentBtn">리뷰 저장</button>
        </div>
    </div>

    <!-- 리뷰 출력창 -->
    <div id="reviewDisplayBox" class="mb-3" <c:if test='${empty myReview.reviewContent}'>style="display: none;"</c:if>>
        <div id="reviewContentBox" class="mb-2" style="white-space: pre-wrap;">${fn:escapeXml(myReview.reviewContent)}</div>
        <div class="text-end">
            <button class="btn btn-link btn-sm p-0 me-2 d-none" id="toggleReviewBtn" data-state="more">더 보기</button>
            <button class="btn btn-outline-secondary btn-sm me-2" id="editReviewBtn">수정</button>
            <button class="btn btn-outline-danger btn-sm" id="deleteReviewBtn">삭제</button>
        </div>
    </div>
</c:if>

<%-- 2. 비로그인 --%>
<c:if test="${empty loginMember}">
    <div id="reviewWriteBox" class="mb-3" style="max-width: 600px; width: 100%; cursor: pointer;" data-bs-toggle="modal" data-bs-target="#loginModal">
        <textarea id="reviewContentInput" class="form-control border-0 border-bottom rounded-0 px-1 py-2" rows="1" placeholder="로그인 후 리뷰 작성이 가능합니다." style="width: 100%; resize: none; overflow-y: hidden; background-color: transparent;" readonly></textarea>
        <div class="text-end mt-2">
            <button class="btn btn-dark btn-sm" disabled>리뷰 저장</button>
        </div>
    </div>
</c:if>


<!-- 로그인 모달 및 JS -->
<jsp:include page="/WEB-INF/views/loginModal.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.addEventListener("DOMContentLoaded", function () {

    const movieId = document.getElementById("movieId")?.value;
    const reviewWriteBox = document.getElementById("reviewWriteBox");
    const reviewContentInput = document.getElementById("reviewContentInput");
    const saveBtn = document.getElementById("saveReviewContentBtn");
    const reviewDisplayBox = document.getElementById("reviewDisplayBox");
    const reviewContentBox = document.getElementById("reviewContentBox");
    const toggleReviewBtn = document.getElementById("toggleReviewBtn");
    const editBtn = document.getElementById("editReviewBtn");
    const deleteBtn = document.getElementById("deleteReviewBtn");


    const autoResize = (el) => {
        if (!el) return;
        el.style.height = "auto";
        el.style.height = el.scrollHeight + "px";
    };

    const checkAndApplyTruncation = () => {
        if (!reviewContentBox || !toggleReviewBtn) return;
        const maxHeight = 85;
        
        reviewContentBox.classList.remove("truncated");
        toggleReviewBtn.classList.add("d-none");

        if (reviewContentBox.scrollHeight > maxHeight) {
            reviewContentBox.classList.add("truncated");
            toggleReviewBtn.classList.remove("d-none");
            toggleReviewBtn.textContent = "더 보기";
            toggleReviewBtn.dataset.state = "more";
        }
    };

    if (reviewContentInput) {
        autoResize(reviewContentInput);
        reviewContentInput.addEventListener("input", () => autoResize(reviewContentInput));
        reviewContentInput.addEventListener("keydown", function (event) {
            if (event.key === "Enter" && !event.shiftKey) {
                event.preventDefault();
                saveBtn?.click();
            }
        });
    }

    if (saveBtn) {
        saveBtn.addEventListener("click", function () {
            const content = reviewContentInput.value.trim();
            if (content === "") {
                alert("리뷰 내용을 입력해주세요.");
                return;
            }
            fetch("${pageContext.request.contextPath}/review/saveContent", {
                method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: new URLSearchParams({ movieId, reviewContent: content })
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    alert("리뷰가 저장되었습니다.");

                    reviewContentBox.textContent = content;
                    reviewWriteBox.style.display = "none";
                    reviewDisplayBox.style.display = "block";
                    checkAndApplyTruncation();
                } else {
                    alert(data.message || "저장 실패");
                }
            })
            .catch(error => console.error("Error:", error));
        });
    }


    if (editBtn) {
        editBtn.addEventListener("click", function () {
            reviewWriteBox.style.display = "block";
            reviewDisplayBox.style.display = "none";
            autoResize(reviewContentInput);
            reviewContentInput.focus();
        });
    }


    if (deleteBtn) {
        deleteBtn.addEventListener("click", function () {
            if (!confirm("정말 리뷰를 삭제하시겠습니까?")) return;
            fetch("${pageContext.request.contextPath}/review/deleteReview", {
                method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: new URLSearchParams({ movieId })
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    alert("삭제되었습니다.");

                    reviewDisplayBox.style.display = "none";
                    reviewWriteBox.style.display = "block";
                    reviewContentInput.value = "";
                    autoResize(reviewContentInput);
                } else {
                    alert(data.message || "삭제 실패");
                }
            })
            .catch(error => console.error("Error:", error));
        });
    }

    // '더 보기' 기능 초기 실행 및 이벤트 핸들러
    checkAndApplyTruncation();
    if (toggleReviewBtn) {
        toggleReviewBtn.addEventListener("click", function() {
            if (this.dataset.state === "more") {
                reviewContentBox.classList.remove("truncated");
                this.textContent = "간단히 보기";
                this.dataset.state = "less";
            } else {
                reviewContentBox.classList.add("truncated");
                this.textContent = "더 보기";
                this.dataset.state = "more";
            }
        });
    }
});
</script>