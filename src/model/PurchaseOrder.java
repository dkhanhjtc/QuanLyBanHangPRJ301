package model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class PurchaseOrder implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String code;
    private Integer supplierId;
    private String supplierName;
    private String productId;
    private String productName;
    private int totalQuantity;
    private double totalCost;
    private String status; // 'PENDING', 'APPROVED', 'REJECTED'
    private String rejectReason;
    private int createdBy;
    private String createdByName;
    private int stockBefore;
    private int stockAfter;
    private Timestamp createdAt;

    public PurchaseOrder() {
        this.status = "PENDING";
    }

    public PurchaseOrder(int id, String code, String supplierName, int totalQuantity, double totalCost, String status, String rejectReason, Timestamp createdAt) {
        this.id = id;
        this.code = code;
        this.supplierName = supplierName;
        this.totalQuantity = totalQuantity;
        this.totalCost = totalCost;
        this.status = status;
        this.rejectReason = rejectReason;
        this.createdAt = createdAt;
    }

    public PurchaseOrder(int id, String code, Integer supplierId, String supplierName, String productId, String productName, int totalQuantity, double totalCost, String status, String rejectReason, int createdBy, String createdByName, int stockBefore, int stockAfter, Timestamp createdAt) {
        this.id = id;
        this.code = code;
        this.supplierId = supplierId;
        this.supplierName = supplierName;
        this.productId = productId;
        this.productName = productName;
        this.totalQuantity = totalQuantity;
        this.totalCost = totalCost;
        this.status = status;
        this.rejectReason = rejectReason;
        this.createdBy = createdBy;
        this.createdByName = createdByName;
        this.stockBefore = stockBefore;
        this.stockAfter = stockAfter;
        this.createdAt = createdAt;
    }

    public PurchaseOrder(int id, String code, String supplierName, String productId, String productName, int totalQuantity, double totalCost, String status, String rejectReason, int createdBy, String createdByName, int stockBefore, int stockAfter, Timestamp createdAt) {
        this.id = id;
        this.code = code;
        this.supplierName = supplierName;
        this.productId = productId;
        this.productName = productName;
        this.totalQuantity = totalQuantity;
        this.totalCost = totalCost;
        this.status = status;
        this.rejectReason = rejectReason;
        this.createdBy = createdBy;
        this.createdByName = createdByName;
        this.stockBefore = stockBefore;
        this.stockAfter = stockAfter;
        this.createdAt = createdAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public Integer getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(Integer supplierId) {
        this.supplierId = supplierId;
    }

    public String getSupplierName() {
        return supplierName;
    }

    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }

    public String getProductId() {
        return productId;
    }

    public void setProductId(String productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public int getTotalQuantity() {
        return totalQuantity;
    }

    public void setTotalQuantity(int totalQuantity) {
        this.totalQuantity = totalQuantity;
    }

    public double getTotalCost() {
        return totalCost;
    }

    public void setTotalCost(double totalCost) {
        this.totalCost = totalCost;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getRejectReason() {
        return rejectReason;
    }

    public void setRejectReason(String rejectReason) {
        this.rejectReason = rejectReason;
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

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getFormattedDate() {
        if (createdAt == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm · dd/MM");
        return sdf.format(createdAt);
    }

    @Override
    public String toString() {
        return "PurchaseOrder{" +
                "id=" + id +
                ", code='" + code + '\'' +
                ", supplierName='" + supplierName + '\'' +
                ", totalQuantity=" + totalQuantity +
                ", totalCost=" + totalCost +
                ", status='" + status + '\'' +
                '}';
    }
}

