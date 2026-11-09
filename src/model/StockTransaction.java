package model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class StockTransaction implements Serializable {
    private static final long serialVersionUID = 1L;

    private long transactionId;
    private int productId;
    private String productCode;
    private String productName;
    private int changeQty; // + nhập kho, - bán hàng, +/- kiểm kê điều chỉnh
    private int stockBefore;
    private int stockAfter;
    private String transactionType; // 'SALE', 'IMPORT', 'STOCKTAKE_ADJUST', 'INITIAL'
    private String referenceCode; // Mã đơn, mã phiếu nhập, mã kiểm kê
    private int createdBy;
    private String createdByName;
    private Timestamp createdAt;
    private String note;

    public StockTransaction() {
    }

    public StockTransaction(long transactionId, int productId, int changeQty, int stockBefore, int stockAfter, String transactionType, String referenceCode, int createdBy, Timestamp createdAt, String note) {
        this.transactionId = transactionId;
        this.productId = productId;
        this.changeQty = changeQty;
        this.stockBefore = stockBefore;
        this.stockAfter = stockAfter;
        this.transactionType = transactionType;
        this.referenceCode = referenceCode;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
        this.note = note;
    }

    public StockTransaction(long transactionId, int productId, String productCode, String productName, int changeQty, int stockBefore, int stockAfter, String transactionType, String referenceCode, int createdBy, String createdByName, Timestamp createdAt, String note) {
        this.transactionId = transactionId;
        this.productId = productId;
        this.productCode = productCode;
        this.productName = productName;
        this.changeQty = changeQty;
        this.stockBefore = stockBefore;
        this.stockAfter = stockAfter;
        this.transactionType = transactionType;
        this.referenceCode = referenceCode;
        this.createdBy = createdBy;
        this.createdByName = createdByName;
        this.createdAt = createdAt;
        this.note = note;
    }

    public long getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(long transactionId) {
        this.transactionId = transactionId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getProductCode() {
        return productCode;
    }

    public void setProductCode(String productCode) {
        this.productCode = productCode;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public int getChangeQty() {
        return changeQty;
    }

    public void setChangeQty(int changeQty) {
        this.changeQty = changeQty;
    }

    public int getStockBefore() {
        return stockBefore;
    }

    public void setStockBefore(int stockBefore) {
        this.stockBefore = stockBefore;
    }

    public int getStockAfter() {
        return stockAfter;
    }

    public void setStockAfter(int stockAfter) {
        this.stockAfter = stockAfter;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public String getReferenceCode() {
        return referenceCode;
    }

    public void setReferenceCode(String referenceCode) {
        this.referenceCode = referenceCode;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public String getCreatedByName() {
        return createdByName;
    }

    public void setCreatedByName(String createdByName) {
        this.createdByName = createdByName;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getFormattedDate() {
        if (createdAt != null) {
            return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(createdAt);
        }
        return "-";
    }

    public String getTypeName() {
        if ("SALE".equalsIgnoreCase(transactionType)) return "Bán hàng (POS)";
        if ("IMPORT".equalsIgnoreCase(transactionType)) return "Nhập kho";
        if ("STOCKTAKE_ADJUST".equalsIgnoreCase(transactionType)) return "Kiểm kê điều chỉnh";
        return "Khởi tạo ban đầu";
    }
}

