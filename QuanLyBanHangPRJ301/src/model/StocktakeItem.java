package model;

import java.io.Serializable;

public class StocktakeItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int stocktakeId;
    private String productId;
    private String productName;
    private int systemStock;
    private int actualStock;
    private int variance; // actualStock - systemStock
    private String note;

    // View helpers
    private double costPrice;
    private String imageUrl;
    private String spec;

    public StocktakeItem() {
    }

    public StocktakeItem(int id, int stocktakeId, String productId, String productName, int systemStock, int actualStock, int variance, String note) {
        this.id = id;
        this.stocktakeId = stocktakeId;
        this.productId = productId;
        this.productName = productName;
        this.systemStock = systemStock;
        this.actualStock = actualStock;
        this.variance = variance;
        this.note = note;
    }

    public StocktakeItem(int id, int stocktakeId, String productId, String productName, int systemStock, int actualStock, int variance, String note, double costPrice, String imageUrl, String spec) {
        this.id = id;
        this.stocktakeId = stocktakeId;
        this.productId = productId;
        this.productName = productName;
        this.systemStock = systemStock;
        this.actualStock = actualStock;
        this.variance = variance;
        this.note = note;
        this.costPrice = costPrice;
        this.imageUrl = imageUrl;
        this.spec = spec;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getStocktakeId() {
        return stocktakeId;
    }

    public void setStocktakeId(int stocktakeId) {
        this.stocktakeId = stocktakeId;
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

    public int getSystemStock() {
        return systemStock;
    }

    public void setSystemStock(int systemStock) {
        this.systemStock = systemStock;
    }

    public int getActualStock() {
        return actualStock;
    }

    public void setActualStock(int actualStock) {
        this.actualStock = actualStock;
    }

    public int getVariance() {
        return variance;
    }

    public void setVariance(int variance) {
        this.variance = variance;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public double getCostPrice() {
        return costPrice;
    }

    public void setCostPrice(double costPrice) {
        this.costPrice = costPrice;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getImage() {
        return imageUrl;
    }

    public String getSpec() {
        return spec;
    }

    public void setSpec(String spec) {
        this.spec = spec;
    }

    public double getVarianceCost() {
        return variance * costPrice;
    }

    @Override
    public String toString() {
        return "StocktakeItem{" +
                "id=" + id +
                ", productId='" + productId + '\'' +
                ", productName='" + productName + '\'' +
                ", systemStock=" + systemStock +
                ", actualStock=" + actualStock +
                ", variance=" + variance +
                '}';
    }
}

